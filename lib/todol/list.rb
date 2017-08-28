require 'yaml'
require 'fileutils'
require 'securerandom'

module Todol
  # Object for reading and writing our list
  class List
    # :tasks is a hash of hashes like { id: {}, id2: {} }
    attr_accessor :tasks

    DEFAULT_LOCATION = (File.dirname(__FILE__) + '/.todol').freeze
    def initialize
      FileUtils.touch(DEFAULT_LOCATION) # Ensures it exists
      self.tasks = YAML.load_file(DEFAULT_LOCATION) || {}
    end

    def read(key)
      tasks[key]
    end

    def add(item)
      raise ArguementError unless item.due_date
      item.added_date ||= Date.today.to_s
      item.id ||= item.due_date.to_s + SecureRandom.hex(2)
      tasks.merge!(item.to_h)
      self.tasks = tasks.sort.to_h
      save!
    end

    def remove(item_id)
      tasks.delete(item_id)
      save!
    end

    def save!
      File.open(DEFAULT_LOCATION, 'w') { |f| f.write tasks.to_yaml }
    end

    def remove_all!
      self.tasks = nil
      save!
    end
  end

  # Object representing a single entry of the list
  class Task
    attr_accessor :id,
                  :description,
                  :due_date,
                  :added_date,
                  :labels

    def initialize(options = {})
      options.each { |trait, value| public_send("#{trait}=", value) }
      self.labels ||= []
    end

    def status
      labels.include?('done')
    end

    def to_s
      description.to_s.capitalize + " | Due: #{due_date}"
    end

    def to_h
      {
        id =>
        {
          description: description,
          due_date: due_date,
          added_date: added_date,
          labels: labels
        }
      }
    end

    def pretty_labels
      labels.join(' - ')
    end
  end
end
