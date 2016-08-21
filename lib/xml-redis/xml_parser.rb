# Enable for debugging
# puts "loaded #{__FILE__}"

module XmlRedis
  class XmlParser
    def self.get_xml_content(xml_file)
      xml_file.get_input_stream.read
    end

  end
end
