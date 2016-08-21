# Enable for debugging
# puts "loaded #{__FILE__}"

require 'zip'
require 'redis'

module XmlRedis
  class RedisPublisher

    def self.get_redis
      redis = Redis.new
    end

    def self.publish_zip_file(params={})
      extract_params(params)

      if !FileDownloader.valid_zip?(@@zip_file_path)
        # TODO: use $LOG.error
        puts "Invalid zip file #{@@zip_file_path}"
        return
      end

      Zip::File.open(@@zip_file_path) do |zipfile|
        zipfile.each_with_index do |xmlfile, index|

          content = XmlParser.get_xml_content(xmlfile)
          report = Report.new(xmlfile.name, content)

          progress_string = "#{index+1}/#{zipfile.size} - #{xmlfile.name}"
          publish_report_to_redis_channel(@@redis, @@channel, report, progress_string)
        end
      end
    end

    private
      def self.extract_params(params={})
        @@redis = params[:redis]
        @@channel = params[:redis_channel]
        @@zip_file_path = params[:zip_file_path]
      end

      def self.publish_report_to_redis_channel(redis, channel, report, progress_string)
        if $VERBOSE
          puts "Publishing redis: #{redis}"
          puts "Publishing channel: #{channel}"
          puts "Publishing report: #{report}"
        end

        return false unless redis and channel and report

        if report.published?(redis)
          puts "Skipped report: #{progress_string}"
          return
        end

        puts "publishing report: #{progress_string}"

        redis.set(report.name, report.content)
        redis.publish(channel, redis.get(report.name))
      end

  end
end
