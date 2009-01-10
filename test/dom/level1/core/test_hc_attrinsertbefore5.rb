
###
# This Ruby source file was generated by test-to-ruby.xsl
# and is a derived work from the source document.
# The source document contained the following notice:
=begin

Copyright (c) 2001-2004 World Wide Web Consortium,
(Massachusetts Institute of Technology, Institut National de
Recherche en Informatique et en Automatique, Keio University). All
Rights Reserved. This program is distributed under the W3C's Software
Intellectual Property License. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.
See W3C License http://www.w3.org/Consortium/Legal/ for more details.

=end
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'helper'))

###
# Attempt to append a CDATASection to an attribute which should result
# in a HIERARCHY_REQUEST_ERR.
# @author Curt Arnold
# see[http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-637646024]
# see[http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#ID-952280727]
##
DOMTestCase('hc_attrinsertbefore5') do

  ###
  # Constructor.
  # @param factory document factory, may not be null
  # @throws org.w3c.domts.DOMTestIncompatibleException Thrown if test is not compatible with parser configuration
  ##
  def setup
    ##
    ##   check if loaded documents are supported for content type
    ##
    contentType = getContentType()
    preload(contentType, "hc_staff", true)
  end

  ###
  # Runs the test case.
  # @throws Throwable Any uncaught exception causes test to fail
  #
  def test_hc_attrinsertbefore5
    doc = nil
    acronymList = nil
    testNode = nil
    attributes = nil
    titleAttr = nil
    value = nil
    textNode = nil
    retval = nil
    refChild = nil;

    doc = load_document("hc_staff", true)
      acronymList = doc.getElementsByTagName("acronym")
      testNode = acronymList.item(3)
      attributes = testNode.attributes()
      titleAttr = attributes.getNamedItem("title")
      
      if (("text/html" == getContentType()))
        
    begin
      success = false;
      begin
        textNode = doc.createCDATASection("terday")
      rescue Nokogiri::XML::DOMException => ex
        success = (ex.code == Nokogiri::XML::DOMException::NOT_SUPPORTED_ERR)
      end 
      assert(success, "throw_NOT_SUPPORTED_ERR")
    end

          else
            textNode = doc.createCDATASection("terday")
      
    begin
      success = false;
      begin
        retval = titleAttr.insertBefore(textNode, refChild)
      rescue Nokogiri::XML::DOMException => ex
        success = (ex.code == Nokogiri::XML::DOMException::HIERARCHY_REQUEST_ERR)
      end 
      assert(success, "throw_HIERARCHY_REQUEST_ERR")
    end

         end
       
  end

  ###
  # Gets URI that identifies the test.
  # @return uri identifier of test
  #
  def targetURI
    "http://www.w3.org/2001/DOM-Test-Suite/tests/Level-1/hc_attrinsertbefore5"
  end
end
