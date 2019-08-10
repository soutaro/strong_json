class StrongJSON
  module Type
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

    module WithAlias
      def alias
        defined?(@alias) ? @alias : nil
      end

      def with_alias(name)
        _ = dup.tap do |copy|
          copy.instance_eval do
            @alias = name
          end
        end
      end
    end

    class Base
      include Match
      include WithAlias

      # @dynamic type
      attr_reader :type

      def initialize(type)
        @type = type
      end

      def test(value)
        case @type
        when :any
          true
        when :number
          value.is_a?(Numeric)
        when :integer
          value.is_a?(Integer)
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

        case type
        when :symbol
          value.to_sym
        else
          value
        end
      end

      def to_s
        self.alias&.to_s || @type.to_s
      end

      def ==(other)
        if other.is_a?(Base)
          # @type var other: Base[any]
          other.type == type
        end
      end

      __skip__ = begin
        alias eql? ==
      end
    end

    class Optional
      include Match
      include WithAlias

      # @dynamic type
      attr_reader :type

      def initialize(type)
        @type = type
      end

      def coerce(value, path: ErrorPath.root(self))
        unless value == nil
          @type.coerce(value, path: path.expand(type: @type))
        else
          nil
        end
      end

      def to_s
        self.alias&.to_s || "optional(#{@type})"
      end

      def ==(other)
        if other.is_a?(Optional)
          # @type var other: Optional[any]
          other.type == type
        end
      end

      __skip__ = begin
        alias eql? ==
      end
    end

    class Literal
      include Match
      include WithAlias

      # @dynamic value
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def to_s
        self.alias&.to_s || (_ = @value).inspect
      end

      def coerce(value, path: ErrorPath.root(self))
        raise TypeError.new(path: path, value: value) unless (_ = self.value) == value
        value
      end

      def ==(other)
        if other.is_a?(Literal)
          # @type var other: Literal[any]
          other.value == value
        end
      end

      __skip__ = begin
        alias eql? ==
      end
    end

    class Array
      include Match
      include WithAlias

      # @dynamic type
      attr_reader :type

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
        self.alias&.to_s || "array(#{@type})"
      end

      def ==(other)
        if other.is_a?(Array)
          # @type var other: Array[any]
          other.type == type
        end
      end

      __skip__ = begin
        alias eql? ==
      end
    end

    class Object
      include Match
      include WithAlias

      # @dynamic fields, on_unknown, exceptions
      attr_reader :fields, :on_unknown, :exceptions

      def initialize(fields, on_unknown:, exceptions:)
        @fields = fields
        @on_unknown = on_unknown
        @exceptions = exceptions
      end

      def coerce(object, path: ErrorPath.root(self))
        unless object.is_a?(::Hash)
          raise TypeError.new(path: path, value: object)
        end

        object = object.dup
        unknown_attributes = Set.new(object.keys) - fields.keys

        case on_unknown
        when :reject
          unknown_attributes.each do |attr|
            if exceptions.member?(attr)
              object.delete(attr)
            else
              raise UnexpectedAttributeError.new(path: path, attribute: attr)
            end
          end
        when :ignore
          unknown_attributes.each do |attr|
            if exceptions.member?(attr)
              raise UnexpectedAttributeError.new(path: path, attribute: attr)
            else
              object.delete(attr)
            end
          end
        end

        # @type var result: ::Hash[Symbol, any]
        result = {}

        fields.each do |key, type|
          result[key] = type.coerce(object[key], path: path.dig(key: key, type: type))
        end

        _ = result
      end

      # @type method ignore: (*Symbol, ?except: Set[Symbol]?) -> Object[T]
      def ignore(*ignores, except: nil)
        if ignores.empty? && !except
          Object.new(fields, on_unknown: :ignore, exceptions: Set[])
        else
          if except
            Object.new(fields, on_unknown: :ignore, exceptions: except)
          else
            Object.new(fields, on_unknown: :reject, exceptions: Set.new(ignores))
          end
        end
      end

      # @type method reject: (*Symbol, ?except: Set[Symbol]?) -> Object[T]
      def reject(*rejecteds, except: nil)
        if rejecteds.empty? && !except
          Object.new(fields, on_unknown: :reject, exceptions: Set[])
        else
          if except
            Object.new(fields, on_unknown: :reject, exceptions: except)
          else
            Object.new(fields, on_unknown: :ignore, exceptions: Set.new(rejecteds))
          end
        end
      end

      def update_fields
        fields.dup.yield_self do |fields|
          yield fields

          Object.new(fields, on_unknown: on_unknown, exceptions: exceptions)
        end
      end

      def to_s
        fields = @fields.map do |name, type|
          "#{name}: #{type}"
        end

        self.alias&.to_s || "object(#{fields.join(', ')})"
      end

      def ==(other)
        if other.is_a?(Object)
          # @type var other: Object[any]
          other.fields == fields &&
            other.on_unknown == on_unknown &&
            other.exceptions == exceptions
        end
      end

      __skip__ = begin
        alias eql? ==
      end
    end

    class Enum
      include Match
      include WithAlias

      # @dynamic types, detector
      attr_reader :types
      attr_reader :detector

      def initialize(types, detector = nil)
        @types = types
        @detector = detector
      end

      def to_s
        self.alias&.to_s || "enum(#{types.map(&:to_s).join(", ")})"
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
          rescue UnexpectedAttributeError, TypeError # rubocop:disable Lint/HandleExceptions
          end
        end

        raise TypeError.new(path: path, value: value)
      end

      def ==(other)
        if other.is_a?(Enum)
          # @type var other: Enum[any]
          other.types == types &&
            other.detector == detector
        end
      end

      __skip__ = begin
        alias eql? ==
      end
    end

    class Hash
      include Match
      include WithAlias

      # @dynamic type
      attr_reader :type

      def initialize(type)
        @type = type
      end

      def coerce(value, path: ErrorPath.root(self))
        if value.is_a?(::Hash)
          (_ = {}).tap do |result|
            value.each do |k, v|
              result[k] = type.coerce(v, path: path.dig(key: k, type: type))
            end
          end
        else
          raise TypeError.new(path: path, value: value)
        end
      end

      def ==(other)
        if other.is_a?(Hash)
          # @type var other: Hash[any]
          other.type == type
        end
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

    class TypeError < StandardError
      # @dynamic path, value
      attr_reader :path, :value

      def initialize(path:, value:)
        @path = path
        @value = value
        type = path.type
        s = type.alias || type
        super "TypeError at #{path.to_s}: expected=#{s}, value=#{value.inspect}"
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
