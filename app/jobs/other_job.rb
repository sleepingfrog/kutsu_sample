# frozen_string_literal: true
class OtherJob < ApplicationJob
  queue_as :other

  def perform(*args)
    raise
  end
end
