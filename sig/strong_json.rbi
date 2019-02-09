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
end

type StrongJSON::ty = _Schema<any>

module StrongJSON::Types
  def object: <'x> (Hash<Symbol, ty>) -> Type::Object<'x>
            | () -> Type::Object<Hash<Symbol, any>>
  def object?: <'x> (Hash<Symbol, ty>) -> Type::Optional<'x>
  def any: () -> Type::Base<any>
  def optional: <'x> (_Schema<'x>) -> Type::Optional<'x>
              | () -> Type::Optional<any>
  def string: () -> Type::Base<String>
  def string?: () -> Type::Optional<String>
  def number: () -> Type::Base<Numeric>
  def number?: () -> Type::Optional<Numeric>
  def numeric: () -> Type::Base<Numeric>
  def numeric?: () -> Type::Optional<Numeric>
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
  def ignored: () -> _Schema<nil>
  def prohibited: () -> _Schema<nil>
end
