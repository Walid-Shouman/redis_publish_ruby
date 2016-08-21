# Enable for debugging
# puts "loaded #{__FILE__}"

require 'fileutils'

module XmlRedis
  class FileDownloader
    def self.create_download_dir
      default_download_dir = File.join(File.dirname(__FILE__), "..", "..", "downloads")
      download_dir = ENV['XML_REDIS_DOWNLOAD_DIR'] || default_download_dir
      FileUtils::mkdir_p(download_dir) unless Dir.exist?(download_dir)
      return download_dir
    end

    def self.download_posts(params={})
      extract_params(params)

      posts_len = @@posts.size

      @@posts.each_with_index do |post, index|
        file_name = post.name

        puts "Downloading file: #{index+1}/#{posts_len}"

        post.print_pretty

        download_file_path = file_path(@@download_dir, file_name)

        if post.downloaded?(@@redis) and zip_file_available_and_valid?(download_file_path) then
          puts "Skip previously downloaded: #{post.name}"
        else
          download_file_handle = File.new(download_file_path, "w")
          remote_file = concatenate_url(@@posts_url, file_name)
          puts "Download link: #{remote_file}"

          download_file(remote_file, download_file_handle)
          post.set_downloaded(@@redis)

          puts "Succesfully downloaded: #{file_name}"
        end

        @@callback_params[:zip_file_path] = download_file_path
        @@callback.call(@@callback_params)

      end
    end

    private
      def self.extract_params(params)
        @@posts_url = params[:posts_url]
        @@posts = params[:posts]
        @@download_dir = params[:download_dir]
        @@detailed = params[:detailed] || false
        @@redis = params[:redis]
        @@callback = params[:callback] || nil
        @@callback_params = params[:callback_params] || nil
      end

      def self.file_path(base_url, file_name)
        File.join(base_url, file_name)
      end

      def self.concatenate_url(base_url, extension)
        URI.join(base_url, extension)
      end

      def self.download_file(remote_file, download_file)
        open(remote_file) do |remote_file|
           File.open(download_file,"wb") do |file|
             IO.copy_stream(remote_file, file)
           end
        end
      end

      def self.zip_file_available_and_valid?(download_file_path)
        File.exist?(download_file_path) and valid_zip?(download_file_path)
      end

      def self.valid_zip?(file)
        zip = Zip::File.open(file)
        true
      rescue StandardError
        false
      ensure
        zip.close if zip
      end

  end
end
