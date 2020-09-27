class SampleJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts 'Preform!'
  end
end
