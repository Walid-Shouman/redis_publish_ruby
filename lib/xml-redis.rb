# Enable for debugging
# puts "loaded #{__FILE__}"

# Require_core_extensions
Dir[File.join(File.dirname(__FILE__), "core_ext", "*.rb")].each {|l| require File.expand_path(l) }

# Enable for debugging
# require 'pry'

require_relative 'xml-redis/post'
require_relative 'xml-redis/report'
require_relative 'xml-redis/xml_parser'
require_relative 'xml-redis/post_loader'
require_relative 'xml-redis/redis_publisher'
require_relative 'xml-redis/file_downloader'

module XmlRedis

  # NOTE: env_var could be true or "false", to_boolean captures true, false
  $VERBOSE = ENV['XML_REDIS_VERBOSE_MODE'] ? ENV['XML_REDIS_VERBOSE_MODE'].to_boolean : false
  posts_url = ENV['XML_REDIS_POSTS_URL'] || "http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/"
  redis_channel = ENV['XML_REDIS_CHANNEL'] || "NEWS_XML"
  detailed_mode = ENV['XML_REDIS_DETAILED_MODE'] ? ENV['XML_REDIS_DETAILED_MODE'].to_boolean : true

  posts = PostLoader.fetch(posts_url, detailed_mode)

  redis = RedisPublisher.get_redis

  download_dir = FileDownloader.create_download_dir

  publish_callable = RedisPublisher.method(:publish_zip_file)
  publish_params = { redis: redis, redis_channel: redis_channel }

  files = FileDownloader.download_posts({ posts_url: posts_url,
                                          posts: posts,
                                          download_dir: download_dir,
                                          redis: redis,
                                          detailed: detailed_mode,
                                          callback: publish_callable,
                                          callback_params: publish_params })

end
