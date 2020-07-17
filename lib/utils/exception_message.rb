# frozen_string_literal: true

module Utils
  class ExceptionMessage

    def self.formater(e)
      return if e.blank?
      bc = ActiveSupport::BacktraceCleaner.new
      bc.add_silencer{|line| line =~ /puma|rubies|gems|rubygems/ }
      backtrace = bc.clean(e.backtrace)

      error_traces = backtrace.select{|l| l.start_with?(Application.config.root.to_s)}
      error_traces = backtrace if error_traces.blank?
      error_traces.unshift(e.message).join("\n")
    end
  end
end
