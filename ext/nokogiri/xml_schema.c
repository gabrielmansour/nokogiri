#include <xml_schema.h>

static void dealloc(xmlSchemaPtr schema)
{
  NOKOGIRI_DEBUG_START(doc);
  xmlSchemaFree(schema);
  NOKOGIRI_DEBUG_END(doc);
}

/*
 * call-seq:
 *  read_memory(string)
 *
 * Create a new Schema from the contents of +string+
 */
static VALUE read_memory(VALUE klass, VALUE content)
{

  xmlSchemaParserCtxtPtr ctx = xmlSchemaNewMemParserCtxt(
      (const char *)StringValuePtr(content),
      RSTRING_LEN(content)
  );

  VALUE errors = rb_ary_new();
  xmlSetStructuredErrorFunc((void *)errors, Nokogiri_error_array_pusher);

  xmlSchemaSetParserStructuredErrors(
      ctx,
      Nokogiri_error_array_pusher,
      (void *)errors
  );

  xmlSchemaPtr schema = xmlSchemaParse(ctx);

  xmlSetStructuredErrorFunc(NULL, NULL);
  xmlSchemaFreeParserCtxt(ctx);

  VALUE rb_schema = Data_Wrap_Struct(klass, 0, 0, schema);
  rb_iv_set(rb_schema, "@errors", errors);

  return rb_schema;
}

VALUE cNokogiriXmlSchema;
void init_xml_schema()
{
  VALUE nokogiri = rb_define_module("Nokogiri");
  VALUE xml = rb_define_module_under(nokogiri, "XML");
  VALUE klass = rb_define_class_under(xml, "Schema", rb_cObject);

  cNokogiriXmlSchema = klass;

  rb_define_singleton_method(klass, "read_memory", read_memory, 1);
}
