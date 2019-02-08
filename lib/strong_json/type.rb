class StrongJSON
  module Type
    NONE = ::Object.new

    module Match
      def =~(value)
        coerce(value)
        true
      rescue
        false
      end

      def ===(value)
        self =~ value
      end
    end

    class Base
      include Match

      # @dynamic type
      attr_reader :type

      def initialize(type)
        @type = type
      end

      def test(value)
        case @type
        when :ignored
          true
        when :any
          true
        when :number
          value.is_a?(Numeric)
        when :string
          value.is_a?(String)
        when :boolean
          value == true || value == false
        when :numeric
          value.is_a?(Numeric) || value.is_a?(String) && /\A[\-\+]?[\d.]+\Z/ =~ value
        when :symbol
          value.is_a?(String) || value.is_a?(Symbol)
        else
          false
        end
      end

      def coerce(value, path: [])
        raise Error.new(value: value, type: self, path: path) unless test(value)
        raise IllegalTypeError.new(type: self) if path == [] && @type == :ignored

        case type
        when :ignored
          NONE
        when :symbol
          value.to_sym
        else
          value
        end
      end

      def to_s
        @type.to_s
      end
    end

    class Optional
      include Match

      def initialize(type)
        @type = type
      end

      def coerce(value, path: [])
        unless value == nil || NONE.equal?(value)
          @type.coerce(value, path: path)
        else
          nil
        end
      end

      def to_s
        "optional(#{@type})"
      end
    end

    class Literal
      include Match

      # @dynamic value
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def to_s
        "literal(#{@value})"
      end

      def coerce(value, path: [])
        raise Error.new(path: path, type: self, value: value) unless (_ = self.value) == value
        value
      end
    end

    class Array
      include Match

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
      include Match

      def initialize(fields)
        @fields = fields
      end

      def coerce(object, path: [])
        unless object.is_a?(Hash)
          raise Error.new(path: path, type: self, value: object)
        end

        # @type var result: ::Hash<Symbol, any>
        result = {}

        object.each do |key, value|
          unless @fields.key?(key)
            raise UnexpectedFieldError.new(path: path + [key], value: value)
          end
        end

        @fields.each do |key, type|
          value = object.key?(key) ? object[key] : NONE

          test_value_type(path + [key], type, value) do |v|
            result[key] = v
          end
        end

        _ = result
      end

      def test_value_type(path, type, value)
        v = type.coerce(value, path: path)

        return if NONE.equal?(v) || NONE.equal?(type)
        return if type.is_a?(Optional) && NONE.equal?(value)

        yield(v)
      end

      def merge(fields)
        # @type var fs: Hash<Symbol, _Schema<any>>

        fs = case fields
             when Object
               fields.instance_variable_get(:"@fields")
             when Hash
               fields
             end

        Object.new(@fields.merge(fs))
      end

      def except(*keys)
        Object.new(keys.each.with_object(@fields.dup) do |key, hash|
                     hash.delete key
                   end)
      end

      def to_s
        # @type var fields: ::Array<String>
        fields = []

        @fields.each do |name, type|
          fields << "#{name}: #{type}"
        end

        "object(#{fields.join(', ')})"
      end
    end

    class Enum
      include Match

      # @dynamic types, detector
      attr_reader :types
      attr_reader :detector

      def initialize(types, detector = nil)
        @types = types
        @detector = detector
      end

      def to_s
        "enum(#{types.map(&:to_s).join(", ")})"
      end

      def coerce(value, path: [])
        if d = detector
          type = d[value]
          if type && types.include?(type)
            return type.coerce(value, path: path)
          end
        end

        types.each do |ty|
          begin
            return ty.coerce(value, path: path)
          rescue UnexpectedFieldError, IllegalTypeError, Error # rubocop:disable Lint/HandleExceptions
          end
        end

        raise Error.new(path: path, type: self, value: value)
      end
    end

    class UnexpectedFieldError < StandardError
      # @dynamic path, value
      attr_reader :path, :value

      def initialize(path: , value:)
        @path = path
        @value = value
      end

      def to_s
        position = "#{path.join('.')}"
        "Unexpected field of #{position} (#{value})"
      end
    end

    class IllegalTypeError < StandardError
      # @dynamic type
      attr_reader :type

      def initialize(type:)
        @type = type
      end

      def to_s
        "#{type} can not be put on toplevel"
      end
    end

    class Error < StandardError
      # @dynamic path, type, value
      attr_reader :path, :type, :value

      def initialize(path:, type:, value:)
        @path = path
        @type = type
        @value = value
      end

      def to_s
        position = path.empty? ? "" : " at .#{path.join('.')}"
        "Expected type of value #{value}#{position} is #{type}"
      end
    end
  end
end
