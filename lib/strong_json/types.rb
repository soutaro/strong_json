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

    def prohibited
      StrongJSON::Type::Base.new(:prohibited)
    end
  end
end
