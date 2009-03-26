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
    end
  end
end
