# frozen_string_literal: true
class OtherWorker
  include Sneakers::Worker
  from_queue "other",
    prefetch: 10,
    arguments: {
      'x-dead-letter-exchange': 'other-retry',
    }

  def work(msg)
    job_data = ActiveSupport::JSON.decode(msg)
    ActiveJob::Base.execute(job_data)
    ack!
  end
end
