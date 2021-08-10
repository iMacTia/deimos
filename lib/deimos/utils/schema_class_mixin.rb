# frozen_string_literal: true

module Deimos
  module Utils
    # Module with Quality of Life methods used in SchemaClassGenerator and Consumer/Producer interfaces
    module SchemaClassMixin
      # @param schema [String] the current schema.
      # @return [String] the schema name, without its namespace.
      def extract_schema(schema)
        last_dot = schema.rindex('.')
        schema[last_dot + 1..-1] || 'ERROR'
      end

      # @param schema [String] the current schema.
      # @return [String] the schema namespace, without its name.
      def extract_namespace(schema)
        last_dot = schema.rindex('.')
        schema[0...last_dot] || 'ERROR'
      end

      # @param schema [Avro::Schema::NamedSchema] A named schema
      # @return [String]
      def schema_classname(schema)
        schema.name.underscore.camelize
      end

      # @param schema [String] the current schema name as a string
      # @return [Class] the Class of the current schema.
      def classified_schema(schema)
        "Deimos::#{schema.underscore.camelize}".safe_constantize
      end

      # Converts a raw payload into an instance of the Schema Class
      # @param payload [Hash]
      # @param schema [String]
      # @return [Deimos::SchemaRecord]
      def schema_class_record(payload, schema)
        klass = classified_schema(schema)
        return payload if klass.nil?

        klass.initialize_from_payload(payload)
      end

      # @param config [FigTree::ConfigStruct] Producer or Consumer config
      # @return [Boolean]
      def use_schema_class?(config)
        use_schema_class = config[:use_schema_class]
        config_type = self.class.ancestors.include?(Consumer) ? Deimos.config.consumers : Deimos.config.producers
        use_schema_class.present? ? use_schema_class : config_type.use_schema_class
      end
    end
  end
end
