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

      def coerce(value, path: ErrorPath.root(self))
        raise TypeError.new(value: value, path: path) unless test(value)
        raise IllegalTopTypeError.new(type: self) if path.root? && @type == :ignored

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

      def coerce(value, path: ErrorPath.root(self))
        unless value == nil || NONE.equal?(value)
          @type.coerce(value, path: path.expand(type: @type))
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

      def coerce(value, path: ErrorPath.root(self))
        raise TypeError.new(path: path, value: value) unless (_ = self.value) == value
        value
      end
    end

    class Array
      include Match

      def initialize(type)
        @type = type
      end

      def coerce(value, path: ErrorPath.root(self))
        if value.is_a?(::Array)
          value.map.with_index do |v, i|
            @type.coerce(v, path: path.dig(key: i, type: @type))
          end
        else
          raise TypeError.new(path: path, value: value)
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

      def coerce(object, path: ErrorPath.root(self))
        unless object.is_a?(Hash)
          raise TypeError.new(path: path, value: object)
        end

        # @type var result: ::Hash<Symbol, any>
        result = {}

        object.each do |key, value|
          unless @fields.key?(key)
            raise UnexpectedAttributeError.new(path: path, attribute: key)
          end
        end

        @fields.each do |key, type|
          value = object.key?(key) ? object[key] : NONE

          test_value_type(path.dig(key: key, type: type), type, value) do |v|
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
        fields = @fields.map do |name, type|
          "#{name}: #{type}"
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

      def coerce(value, path: ErrorPath.root(self))
        if d = detector
          type = d[value]
          if type && types.include?(type)
            return type.coerce(value, path: path.expand(type: type))
          end
        end

        types.each do |ty|
          begin
            return ty.coerce(value, path: path.expand(type: ty))
          rescue UnexpectedAttributeError, IllegalTopTypeError, TypeError # rubocop:disable Lint/HandleExceptions
          end
        end

        raise TypeError.new(path: path, value: value)
      end
    end

    class UnexpectedAttributeError < StandardError
      # @dynamic path, attribute
      attr_reader :path, :attribute

      def initialize(path:, attribute:)
        @path = path
        @attribute = attribute
        super "UnexpectedAttributeError at #{path.to_s}: attribute=#{attribute}"
      end

      def type
        path.type
      end
    end

    class IllegalTopTypeError < StandardError
      # @dynamic type
      attr_reader :type

      def initialize(type:)
        @type = type
        super "IllegalTopTypeError: type=#{type}"
      end
    end

    class TypeError < StandardError
      # @dynamic path, value
      attr_reader :path, :value

      def initialize(path:, value:)
        @path = path
        @value = value
        super "TypeError at #{path.to_s}: expected=#{path.type}, value=#{value.inspect}"
      end

      def type
        path.type
      end
    end

    class ErrorPath
      # @dynamic type, parent
      attr_reader :type, :parent

      def initialize(type:, parent:)
        @type = type
        @parent = parent
      end

      def dig(key:, type:)
        # @type var parent: [Integer | Symbol | nil, ErrorPath]
        parent = [key, self]
        self.class.new(type: type, parent: parent)
      end

      def expand(type:)
        # @type var parent: [Integer | Symbol | nil, ErrorPath]
        parent = [nil, self]
        self.class.new(type: type, parent: parent)
      end

      def self.root(type)
        self.new(type: type, parent: nil)
      end

      def root?
        !parent
      end

      def to_s
        if pa = parent
          if key = pa[0]
            pa[1].to_s + case key
                         when Integer
                           "[#{key}]"
                         when Symbol
                           ".#{key}"
                         end
          else
            pa[1].to_s
          end
        else
          "$"
        end
      end
    end
  end
end
