class StrongJSON
  module Type
    class Base
      def initialize(type)
        @type = type
      end

      def test(value)
        case @type
        when :prohibited
          false
        when :any
          true
        when :number
          value.is_a?(Numeric)
        when :string
          value.is_a?(String)
        when :boolean
          value == true || value == false
        when :numeric
          value.is_a?(Numeric) || value.is_a?(String) && /\A[\d.]+\Z/ =~ value
        else
          false
        end
      end

      def coerce(value, path: [])
        raise Error.new(value: value, type: self, path: path) unless test(value)
        value
      end

      def to_s
        @type.to_s
      end
    end

    class Optional
      def initialize(type)
        @type = type
      end

      def coerce(value, path: [])
        if value != nil
          @type.coerce(value, path: path)
        else
          nil
        end
      end

      def to_s
        "optinal(#{@type})"
      end
    end

    class Array
      def initialize(type)
        @type = type
      end

      def coerce(value, path: [])
        if value.is_a?(::Array)
          value.map.with_index do |v, i|
            @type.coerce(v, path: path+[i])
          end
        else
          raise Error.new(path: path, type: self, value: value)
        end
      end

      def to_s
        "array(#{@type})"
      end
    end

    class Object
      def initialize(fields)
        @fields = fields
      end

      def coerce(object, path: [])
        unless object.is_a?(Hash)
          raise Error.new(path: path, type: self, value: object)
        end

        result = {}

        @fields.each do |name, ty|
          value = ty.coerce(object[name], path: path + [name])
          result[name] = value if object.has_key?(name)
        end

        result
      end

      def merge(fields)
        if fields.is_a?(Object)
          fields = Object.instance_variable_get("@fields")
        end

        Object.new(@fields.merge(fields))
      end

      def to_s
        fields = []

        @fields.each do |name, type|
          fields << "#{name}: #{type}"
        end

        "object(#{fields.join(', ')})"
      end
    end

    class Error < StandardError
      attr_reader :path, :type, :value

      def initialize(path:, type:, value:)
        @path = path
        @type = type
        @value = value
      end

      def to_s
        "Expected type of value at #{path.join('.')} (#{value}) is #{type}"
      end
    end
  end
end
