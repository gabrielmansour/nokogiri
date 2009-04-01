module Nokogiri
  module XML
    class XPathContext
      
      attr_accessor :cstruct

      def register_ns(prefix, uri)
        LibXML.xmlXPathRegisterNs(cstruct, prefix, uri)
      end

      def evaluate(search_path, xpath_handler=nil)
        lookup = nil # to keep lambda in scope long enough to avoid a possible GC tragedy
        query = search_path.to_s

        if xpath_handler
          lookup = lambda do |ctx, name, uri|
            return nil unless xpath_handler.respond_to?(name)
            ruby_funcall name, xpath_handler
          end
          LibXML.xmlXPathRegisterFuncLookup(cstruct, lookup, nil);
        end

        exception_handler = lambda do |ctx, error|
          raise XPath::SyntaxError.wrap(error)
        end
        LibXML.xmlResetLastError()
        LibXML.xmlSetStructuredErrorFunc(nil, exception_handler)

        generic_exception_handler = lambda do |ctx, msg|
          raise RuntimeError.new(msg) # TODO: varargs
        end
        LibXML.xmlSetGenericErrorFunc(nil, generic_exception_handler)

        xpath_ptr = LibXML.xmlXPathEvalExpression(query, cstruct)

        LibXML.xmlSetStructuredErrorFunc(nil, nil)
        LibXML.xmlSetGenericErrorFunc(nil, nil)

        if xpath_ptr.null?
          error = LibXML.xmlGetLastError()
          raise XPath::SyntaxError.wrap(error)
        end

        xpath = XML::XPath.new
        xpath.cstruct = LibXML::XmlXpath.new(xpath_ptr)
        xpath.document = cstruct[:doc]
        xpath
      end

      def self.new(node)
        LibXML.xmlXPathInit()

        ptr = LibXML.xmlXPathNewContext(node.cstruct[:doc])

        ctx = allocate
        ctx.cstruct = LibXML::XmlXpathContext.new(ptr)
        ctx.cstruct[:node] = node.cstruct
        ctx
      end

      private

      #
      #  returns a lambda that will call the handler function with marshalled parameters
      #
      def ruby_funcall(name, xpath_handler)
        lambda do |ctx, nargs|
          parser_context = LibXML::XmlXpathParserContext.new(ctx)
          context = parser_context.context
          doc = context.doc.ruby_doc

          params = []

          nargs.times do |j|
            obj = LibXML::XmlXpathObject.new(LibXML.valuePop(ctx))
            case obj[:type]
            when LibXML::XmlXpathObject::XPATH_STRING
              params.unshift obj[:stringval]
            when LibXML::XmlXpathObject::XPATH_BOOLEAN
              params.unshift obj[:boolval] == 1
            when LibXML::XmlXpathObject::XPATH_NUMBER
              params.unshift obj[:floatval]
            when LibXML::XmlXpathObject::XPATH_NODESET
              params.unshift LibXML::XmlNodeSet.new(obj[:nodesetval])
            else
              params.unshift LibXML.xmlXPathCastToString(obj)
            end
            LibXML.xmlXPathFreeNodeSetList(obj)
          end

          result = xpath_handler.send(name, *params)

          case result.class
          when Fixnum
            LibXML.xmlXPathReturnNumber(ctx, result)
          when String
            LibXML.xmlXPathReturnString(
              ctx,
              LibXML.xmlXPathWrapCString(result)
              )
          when TrueClass
            LibXML.xmlXPathReturnTrue(ctx)
          when FalseClass
            LibXML.xmlXPathReturnFalse(ctx)
          when NilClass
            ;
          when Array
            node_set = XML::NodeSet.new(doc, result)
            LiBXML.xmlXPathReturnNodeSet(
              ctx,
              LibXML.xmlXPathNodeSetMerge(nil, node_set.cstruct)
              )
          else
            if result.is_a?(LibXML::XmlNodeSet)
              LibXML.xmlXPathReturnNodeSet(
                ctx,
                LibXML.xmlXPathNodeSetMerge(nil, result)
                )
            else
              raise RuntimeError.new("Invalid return type #{result.class.inspect}")
            end
          end

        end # lambda
      end # ruby_funcall

    end
  end
end
