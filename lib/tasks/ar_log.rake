# forozen_string_literal: true
task ar_log: :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
