require 'grape_logging'

HTTParty::Logger.add_formatter('custom', HTTParty::Logger::CustomFormatter)
