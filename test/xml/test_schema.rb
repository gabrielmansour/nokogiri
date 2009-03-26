require File.expand_path(File.join(File.dirname(__FILE__), '..', "helper"))

module Nokogiri
  module XML
    class TestSchema < Nokogiri::TestCase
      def test_parse_with_memory
        assert xsd = Nokogiri::XML::Schema(File.read(PO_SCHEMA_FILE))
        assert_instance_of Nokogiri::XML::Schema, xsd
        assert_equal 0, xsd.errors.length
      end

      def test_parse_with_io
        xsd = nil
        File.open(PO_SCHEMA_FILE, 'rb') { |f|
          assert xsd = Nokogiri::XML::Schema(f)
        }
        assert_equal 0, xsd.errors.length
      end

      def test_parse_with_errors
        xml = File.read(PO_SCHEMA_FILE).sub(/name="/, 'name=')
        assert xsd = Nokogiri::XML::Schema(xml)
        assert(xsd.errors.length > 0)
      end
    end
  end
end
