# Enable for debugging
# puts "loaded #{__FILE__}"

module XmlRedis
    class Report
    attr_accessor :name, :content

    def initialize(report_name, report_content)
      self.name = report_name
      self.content = report_content
    end

    def print_csv_record
      print name.empty? ? "," : "\"#{name}\","
      print content.empty? ? "" : "\"#{content}\","
      p "\n"
    end

    def published?(redis)
      redis ? redis.exists(name) : false
    end

  end
end
