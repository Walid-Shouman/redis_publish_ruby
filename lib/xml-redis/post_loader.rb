# Enable for debugging
# puts "loaded #{__FILE__}"

require 'open-uri'
require 'nokogiri'

module XmlRedis
  class PostLoader
    def self.fetch(posts_url, detailed=false)
      return unless posts_url
      response = load_html(posts_url)

      html_doc = Nokogiri::HTML(response)

      anchors = capture_anchors(html_doc, detailed)

      posts = extract_posts(anchors, detailed)
    end

    private
      # @param [ String ] url with anchor elements.
      #
      # @return [ Tempfile ] html document.
      def self.load_html(url)
        open(url)
      end

      # @param [ Nokogiri::HTML::Document ] html document with anchors.
      #
      # @return [ Nokogiri::XML::NodeSet ] nodeset of all document anchors
      def self.capture_anchors(doc, detailed=false)
        detailed ? doc.xpath("//a/../..") : doc.xpath("//a")
      end

      # Full post data extraction
      #
      # @param [ Nokogiri::XML::NodeSet ] nodeset of anchors.
      #
      # @return [ String/Posts Array ] href array of all file names
      # or posts array in detailed mode
      def self.extract_posts(anchors, detailed=false)
        posts = []

        anchors.each do |anchor|
          href = anchor_href(anchor, detailed)
          if href and !href.empty? and string_zip_extension?(href)
            posts = populate_posts(posts, anchor, detailed)
          end
        end

        posts
      end

      # @param [ Nokogiri::XML::Element ] anchor alement node.
      # @param [ Boolean ] detailed mode
      #
      # @return [ Posts array ] array of posts
      def self.populate_posts(posts, anchor, detailed=false)
        post = Post.new()
        post.name = anchor_href(anchor, detailed)

        if detailed == true then
          post.size = anchor_size(anchor)
          post.modification_time = anchor_time(anchor)
        end

        posts << post
      end

      # @param [ Nokogiri::XML::Element ] anchor alement node.
      # @param [ Boolean ] detailed mode
      #
      # @return [ String ] href value of an anchor
      def self.anchor_href(anchor, detailed=false)
        detailed ? anchor.children.children[0]['href'] : anchor['href']
      end

      # This mehtod is only for the detailed mode
      #
      # @param [ Nokogiri::XML::Element ] anchor alement node.
      #
      # @return [ String ] Size of anchor
      def self.anchor_size(anchor)
        size_str = anchor.children.children[2].to_s
      end

      # This mehtod is only for the detailed mode
      #
      # @param [ Nokogiri::XML::Element ] anchor alement node.
      #
      # @return [ Time ] Modification time of an anchor
      def self.anchor_time(anchor)
        time_str = anchor.children.children[1]
        time = Time.parse(time_str)
      end

      # @param [ String ]
      #
      # @return [ Boolean ] ends with .zip?
      def self.string_zip_extension?(string)
        File.extname(string) == ".zip"
      end

  end
end
