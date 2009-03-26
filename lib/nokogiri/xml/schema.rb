module Nokogiri
  module XML
    class << self
      def Schema string_or_io
        if string_or_io.respond_to?(:read)
          string_or_io = string_or_io.read
        end

        Schema.read_memory(string_or_io)
      end
    end

    class Schema
      # Errors while parsing this schema file
      attr_accessor :errors

      ###
      # Validate +thing+ against this schema.  +thing+ can be a
      # Nokogiri::XML::Document object, or a filename
      def validate thing
        return validate_document(thing) if thing.is_a?(Nokogiri::XML::Document)

        # FIXME libxml2 has an api for validating files.  We should switch
        # to that because it will probably save memory.
        validate_document(Nokogiri::XML(File.read(thing)))
      end

      ###
      # Returns true if +thing+ is a valid Nokogiri::XML::Document or
      # file.
      def valid? thing
        validate(thing).length == 0
      end
    end
  end
end
