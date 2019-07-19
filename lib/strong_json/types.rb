class StrongJSON
  module Types
    # @type method object: (?Hash<Symbol, ty>) -> Type::Object<any>
    def object(fields = {})
      if fields.empty?
        Type::Object.new(fields, on_unknown: :ignore, exceptions: Set.new)
      else
        Type::Object.new(fields, on_unknown: :reject, exceptions: Set.new)
      end
    end

    # @type method array: (?ty) -> Type::Array<any>
    def array(type = any)
      Type::Array.new(type)
    end

    # @type method optional: (?ty) -> Type::Optional<any>
    def optional(type = any)
      Type::Optional.new(type)
    end

    def string
      StrongJSON::Type::Base.new(:string)
    end

    def numeric
      StrongJSON::Type::Base.new(:numeric)
    end

    def number
      StrongJSON::Type::Base.new(:number)
    end

    def integer
      StrongJSON::Type::Base.new(:integer)
    end

    def boolean
      StrongJSON::Type::Base.new(:boolean)
    end

    def any
      StrongJSON::Type::Base.new(:any)
    end

    def any?
      optional(any)
    end

    def symbol
      StrongJSON::Type::Base.new(:symbol)
    end

    def literal(value)
      StrongJSON::Type::Literal.new(value)
    end

    def enum(*types, detector: nil)
      StrongJSON::Type::Enum.new(types, detector)
    end

    def string?
      optional(string)
    end

    def numeric?
      optional(numeric)
    end

    def integer?
      optional(integer)
    end

    def number?
      optional(number)
    end

    def boolean?
      optional(boolean)
    end

    def symbol?
      optional(symbol)
    end

    def array?(ty)
      optional(array(ty))
    end

    # @type method object?: (?Hash<Symbol, ty>) -> Type::Optional<any>
    def object?(fields={})
      optional(object(fields))
    end

    def literal?(value)
      optional(literal(value))
    end

    def enum?(*types, detector: nil)
      optional(enum(*types, detector: detector))
    end

    def hash(type)
      StrongJSON::Type::Hash.new(type)
    end

    def hash?(type)
      optional(hash(type))
    end
  end
end
