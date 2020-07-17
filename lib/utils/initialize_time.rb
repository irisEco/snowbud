module Utils
  class InitializeTime
    def self.start_time(start_date)
      start_date.to_time rescue nil
    end

    def self.end_time(end_date)
      (end_date.to_time + 1.day) rescue nil
    end
  end
end
