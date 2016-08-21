# Enable for debugging
# puts "loaded #{__FILE__}"

module XmlRedis
    class Post
    attr_accessor :name, :size ,:modification_time

    def initialize(params={})
      self.name = params[:name]
      self.size = params[:size]
      self.modification_time = params[:modification_time]
    end

    def print_csv_record
      print name.empty? ? "," : "\"#{name}\","
      print size.empty? ? "," : "\"#{size}\","
      print modification_time.empty? ? "" : "\"#{modification_time}\","
      p "\n"
    end

    def print_pretty
      puts "Size: #{size}" if size
      puts "modification_time: #{modification_time}" if modification_time
    end

    def hash
      size.to_s + modification_time.to_s
    end

    def downloaded?(redis)
      return false if !redis

      value = redis.get(name)
      value and value == self.hash ? true : false
    end

    def set_downloaded(redis)
      return false if !redis

      hash = self.hash
      redis.set(name, hash)
    end

  end
end
