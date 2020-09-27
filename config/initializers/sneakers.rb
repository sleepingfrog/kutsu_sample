# frozen_string_literal: true
require 'sneakers'

Sneakers.configure(
  amqp: ENV['RABBITMQ_URL']
)
