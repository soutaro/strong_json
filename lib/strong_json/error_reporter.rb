class StrongJSON
  class ErrorReporter
    # @dynamic path
    attr_reader :path

    def initialize(path:)
      @path = path
    end

    def to_s
      format() unless @string
      @string
    end

    def format
      @string = ""

      format_trace(path: path)
      where = format_aliases(path: path, where: [])

      # @type var ty: Type::Enum<any>
      if (ty = _ = path.type).is_a?(Type::Enum)
        ty.types.each do |t|
          if (a = t.alias)
            where.push format_single_alias(a, t)
          end
        end
      end

      unless where.empty?
        @string << "\nWhere:\n"
        @string << where.map {|x| x.gsub(/^/, "  ") }.join("\n")
      end
    end

    def format_trace(path:, index: 1)
      @string << (" " * index)
      type_string = pretty_str(path.type)
      if parent = path.parent
        case parent[0]
        when Symbol
          @string << "\"#{parent[0]}\" expected to be #{type_string}\n"
        when Integer
          @string << "#{parent[0]} expected to be #{type_string}\n"
        else
          @string << "Expected to be #{type_string}\n"
        end

        format_trace(path: parent[1], index: index + 1)
      else
        @string << "$ expected to be #{type_string}\n"
      end
    end

    def format_aliases(path:, where:)
      ty = path.type

      if (a = ty.alias)
        where << format_single_alias(a, ty)
      end

      if parent = path.parent
        format_aliases(path: parent[1], where: where)
      end

      where
    end

    def format_single_alias(name, type)
      # @type const PrettyPrint: any
      PrettyPrint.format do |pp|
        pp.text(name.to_s)
        pp.text(" = ")
        pp.group do
          pretty(type, pp, expand_alias: true)
        end
      end
    end

    def pretty_str(type, expand_alias: false)
      # @type const PrettyPrint: any
      PrettyPrint.singleline_format do |pp|
        pretty(type, pp, expand_alias: expand_alias)
      end
    end

    def pretty(type, pp, expand_alias: false)
      if !expand_alias && type.alias
        pp.text type.alias.to_s
      else
        case type
        when Type::Object
          pp.group 0, "{", "}" do
            pp.nest(2) do
              pp.breakable(" ")
              type.fields.each.with_index do |pair, index|
                key, ty = pair
                pp.text "#{key.to_s.inspect}: "
                pretty(ty, pp)
                if index < type.fields.size-1
                  pp.text ","
                  pp.breakable(" ")
                end
              end
            end
            pp.breakable(" ")
          end
        when Type::Enum
          pp.group 0, "enum(", ")" do
            pp.nest(2) do
              pp.breakable("")
              type.types.each.with_index do |ty, index|
                pretty(ty, pp)
                if index < type.types.size - 1
                  pp.text ","
                  pp.breakable " "
                end
              end
            end
            pp.breakable("")
          end
        when Type::Optional
          pp.group 0, "optional(", ")" do
            pp.nest(2) do
              pp.breakable ""
              pretty(type.type, pp)
            end
            pp.breakable ""
          end
        when Type::Array
          pp.group 0, "array(", ")" do
            pp.nest(2) do
              pp.breakable ""
              pretty(type.type, pp)
            end
            pp.breakable ""
          end
        when Type::Base
          pp.text type.type.to_s
        else
          pp.text type.to_s
        end
      end
    end
  end
end
