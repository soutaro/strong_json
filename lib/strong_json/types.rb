class StrongJSON
  module Types
    def object(fields = {})
      Type::Object.new(fields)
    end

    def array(type = any)
      Type::Array.new(type)
    end

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

    def boolean
      StrongJSON::Type::Base.new(:boolean)
    end

    def any
      StrongJSON::Type::Base.new(:any)
    end

    def any?
      optional(any)
    end

    def prohibited
      StrongJSON::Type::Base.new(:prohibited)
    end

    def symbol
      StrongJSON::Type::Base.new(:symbol)
    end

    def literal(value)
      StrongJSON::Type::Literal.new(value)
    end

    def enum(*types)
      StrongJSON::Type::Enum.new(types)
    end

    def string?
      optional(string)
    end

    def numeric?
      optional(numeric)
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

    def ignored
      StrongJSON::Type::Base.new(:ignored)
    end

    def array?(ty)
      optional(array(ty))
    end

    def object?(fields)
      optional(object(fields))
    end

    def literal?(value)
      optional(literal(value))
    end

    def enum?(*types)
      optional(enum(*types))
    end
  end
end
