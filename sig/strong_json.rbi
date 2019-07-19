class StrongJSON
  def initialize: { (self) -> void } -> any
  def let: (Symbol, ty) -> void
  include StrongJSON::Types
end

StrongJSON::VERSION: String

class StandardError
  def initialize: (String) -> any
end

interface StrongJSON::_Schema<'type>
  def coerce: (any, ?path: Type::ErrorPath) -> 'type
  def =~: (any) -> bool
  def to_s: -> String
  def is_a?: (any) -> bool
  def alias: -> Symbol?
  def with_alias: (Symbol) -> self
  def ==: (any) -> bool
  def yield_self: <'a> () { (self) -> 'a } -> 'a
end

type StrongJSON::ty = _Schema<any>

module StrongJSON::Types
  def object: <'x> (Hash<Symbol, ty>) -> Type::Object<'x>
            | () -> Type::Object<{}>
  def object?: <'x> (Hash<Symbol, ty>) -> Type::Optional<'x>
             | () -> Type::Optional<{}>
  def any: () -> Type::Base<any>
  def any?: () -> Type::Optional<any>
  def optional: <'x> (_Schema<'x>) -> Type::Optional<'x>
              | () -> Type::Optional<any>
  def string: () -> Type::Base<String>
  def string?: () -> Type::Optional<String>
  def number: () -> Type::Base<Numeric>
  def number?: () -> Type::Optional<Numeric>
  def numeric: () -> Type::Base<Numeric>
  def numeric?: () -> Type::Optional<Numeric>
  def integer: () -> Type::Base<Integer>
  def integer?: () -> Type::Optional<Integer>
  def boolean: () -> Type::Base<bool>
  def boolean?: () -> Type::Optional<bool>
  def symbol: () -> Type::Base<Symbol>
  def symbol?: () -> Type::Optional<Symbol>
  def array: <'x> (_Schema<'x>) -> Type::Array<'x>
           | () -> Type::Array<any>
  def array?: <'x> (_Schema<'x>) -> Type::Optional<::Array<'x>>
  def literal: <'x> ('x) -> Type::Literal<'x>
  def literal?: <'x> ('x) -> Type::Optional<'x>
  def enum: <'x> (*_Schema<any>, ?detector: Type::detector?) -> Type::Enum<'x>
  def enum?: <'x> (*_Schema<any>, ?detector: Type::detector?) -> Type::Optional<'x>
  def (incompatible) hash: <'x> (_Schema<'x>) -> Type::Hash<'x>
  def hash?: <'x> (_Schema<'x>) -> Type::Optional<Hash<Symbol, 'x>>
end

class StrongJSON::ErrorReporter
  attr_reader path: Type::ErrorPath
  @string: String
  def initialize: (path: Type::ErrorPath) -> any
  def format: -> void
  def (private) format_trace: (path: Type::ErrorPath, ?index: Integer) -> void
  def (private) format_aliases: (path: Type::ErrorPath, where: ::Array<String>) -> ::Array<String>
  def (private) format_single_alias: (Symbol, ty) -> String
  def (private) pretty: (ty, any, ?expand_alias: bool) -> void
  def pretty_str: (ty, ?expand_alias: bool) -> ::String
end
