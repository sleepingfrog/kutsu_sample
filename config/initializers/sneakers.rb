# frozen_string_literal: true
require 'sneakers'
require 'sneakers/handlers/maxretry'

class MyHandler < Sneakers::Handlers::Maxretry
  def handle_retry(hdr, props, msg, reason)
    # +1 for the current attempt
    num_attempts = failure_count(props[:headers]) + 1
    if num_attempts <= @max_retries
      # We call reject which will route the message to the
      # x-dead-letter-exchange (ie. retry exchange) on the queue
      Sneakers.logger.info do
        "#{log_prefix} msg=retrying, count=#{num_attempts}, headers=#{props[:headers]}"
      end
      @channel.reject(hdr.delivery_tag, false)
      # TODO: metrics
    else
      # Retried more than the max times
      # Publish the original message with the routing_key to the error exchange
      Sneakers.logger.info do
        "#{log_prefix} msg=failing, retry_count=#{num_attempts}, reason=#{reason}"
      end
      data = {
        error: reason.to_s,
        num_attempts: num_attempts,
        failed_at: Time.now.iso8601,
        properties: props.to_hash
      }.tap do |hash|
        if reason.is_a?(Exception)
          hash[:error_class] = reason.class.to_s
          hash[:error_message] = "#{reason}"
          if reason.backtrace
            hash[:backtrace] = reason.backtrace.take(10)
          end
        end
      end

      # Preserve retry log in a list
      if retry_info = props[:headers]['retry_info']
        old_retry0 = JSON.parse(retry_info) rescue {error: "Failed to parse retry info"}
        old_retry  = Array(old_retry0)
        # Prevent old retry from nesting
        data[:properties][:headers].delete('retry_info')
        data = old_retry.unshift(data)
      end

      @error_exchange.publish(msg, {
        routing_key: hdr.routing_key,
        headers: {
          retry_info: data.to_json
        }
      })
      @channel.acknowledge(hdr.delivery_tag, false)
      # TODO: metrics
    end
  end
  private :handle_retry
end

Sneakers.configure(
  amqp: ENV['RABBITMQ_URL'],
  handler: MyHandler,
  retry_max_times: 2,
)
