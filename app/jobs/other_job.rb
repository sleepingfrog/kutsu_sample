# frozen_string_literal: true
class OtherJob < ApplicationJob
  queue_as :other

  def perform(*args)
    raise if Random.rand(1..5) == 1
  end
end
