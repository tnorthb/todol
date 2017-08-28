require 'todol/version'
require 'highline'
require 'todol/list'

module Todol
  # Defines functions the user directly interacts with.
  class Interface
    # TODO: Colorscheming, more prettifiers
    attr_accessor :list,
                  :cli
    def initialize
      self.list = List.new
      self.cli = HighLine.new
    end

    def start
      pretty_print_list if list.tasks.any?

      loop do
        cli.choose do |menu|
          menu.prompt = 'What are we doing?'
          menu.choice('Add a task') { add_task }
          menu.choice('Remove a task') { cli.say('Removed') } # TODO
          menu.choice('Exit') { cli.say('Goodbye!') || exit }
        end
      end
    end

    def add_task
      todo = Task.new
      todo.description = cli.ask('Describe the task?')
      todo.due_date = cli.ask('When is it due? (yyyy-mm-dd)', Date)
      todo.labels = ask_labels
      prompt_are_you_sure(todo)
    end

    def remove_task
    end

    def prompt_are_you_sure(todo)
      cli.say('Confirm:')
      confirmable_fields = [:description, :due_date, :labels]
      confirmable_fields.each do |field|
        cli.say("#{field.to_s} - #{todo.send(field)}")
      end

      loop do
        cli.choose do |menu|
          menu.prompt = 'Save this task?'
          menu.choice('Save') do
            list.add(todo)
            cli.say('Saved!')
            start
          end

          menu.choice('Start over') { add_task }
          menu.choice('Exit Todol') { cli.say('Goodbye!') || exit }
        end
      end
    end

    def pretty_print_list
      cli.say('TODO:')
      list.tasks.each do |item|3
        task = Task.new(item[1])
        cli.say(task.to_s)
      end
    end

    def ask_labels
      cli.ask('Labels to add?  (comma separated list)', lambda do |str|
                                                          if str.class != String
                                                            cli.say('Ignoring labels, invalid entry')
                                                            next
                                                          end

                                                          str.split(/,\s*/)
                                                        end)
    end
  end
end
