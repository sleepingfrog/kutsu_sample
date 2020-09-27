# frozen_string_literal: true
class OtherWorker
  include Sneakers::Worker
  from_queue "other",
    prefetch: 1

  def work(msg)
    job_data = ActiveSupport::JSON.decode(msg)
    ActiveJob::Base.execute(job_data)
    ack!
  end
end
