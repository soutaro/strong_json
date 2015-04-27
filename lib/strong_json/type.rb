class StrongJSON
  module Type
    NONE = ::Object.new

    class Base
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
        else
          false
        end
      end

      def coerce(value, path: [])
        raise Error.new(value: value, type: self, path: path) unless test(value)
        raise IllegalTypeError.new(type: self) if path == [] && @type == :ignored
        @type != :ignored ? value : NONE
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
        unless value == nil || NONE.equal?(value)
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

        all_keys = (@fields.keys + object.keys).sort.uniq
        all_keys.each do |key|
          type = @fields.has_key?(key) ? @fields[key] : NONE
          value = object.has_key?(key) ? object[key] : NONE

          test_value_type(path + [key], type, value) do |v|
            result[key] = v
          end
        end

        result
      end

      def test_value_type(path, type, value)
        if NONE.equal?(type) && !NONE.equal?(value)
          raise UnexpectedFieldError.new(path: path, value: value)
        end

        v = type.coerce(value, path: path)

        return if NONE.equal?(v) || NONE.equal?(type)
        return if type.is_a?(Optional) && NONE.equal?(value)

        yield(v)
      end

      def merge(fields)
        if fields.is_a?(Object)
          fields = Object.instance_variable_get("@fields")
        end

        Object.new(@fields.merge(fields))
      end

      def except(*keys)
        Object.new(keys.each.with_object(@fields.dup) do |key, hash|
                     hash.delete key
                   end)
      end

      def to_s
        fields = []

        @fields.each do |name, type|
          fields << "#{name}: #{type}"
        end

        "object(#{fields.join(', ')})"
      end
    end

    class UnexpectedFieldError < StandardError
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
      attr_reader :type

      def initialize(type:)
        @type = type
      end

      def to_s
        "#{type} can not be put on toplevel"
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
        position = path.empty? ? "" : " at .#{path.join('.')}"
        "Expected type of value #{value}#{position} is #{type}"
      end
    end
  end
end
