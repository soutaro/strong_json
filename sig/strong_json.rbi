class StrongJSON
  def initialize: { (self) -> void } -> any
  def let: (Symbol, ty) -> void
  include StrongJSON::Types
end

StrongJSON::VERSION: String

interface StrongJSON::_Schema<'type>
  def coerce: (any, ?path: ::Array<Symbol>) -> 'type
  def =~: (any) -> bool
  def to_s: -> String
  def is_a?: (any) -> bool
end

type StrongJSON::ty = _Schema<any>

module StrongJSON::Types
  def object: <'x> (Hash<Symbol, ty>) -> _Schema<'x>
            | () -> _Schema<Hash<Symbol, any>>
  def object?: <'x> (Hash<Symbol, ty>) -> _Schema<'x | nil>
  def any: () -> _Schema<any>
  def optional: <'x> (?_Schema<'x>) -> _Schema<'x | nil>
              | () -> _Schema<any>
  def string: () -> _Schema<String>
  def string?: () -> _Schema<String?>
  def number: () -> _Schema<Numeric>
  def number?: () -> _Schema<Numeric?>
  def numeric: () -> _Schema<Numeric>
  def numeric?: () -> _Schema<Numeric?>
  def boolean: () -> _Schema<bool>
  def boolean?: () -> _Schema<bool?>
  def symbol: () -> _Schema<Symbol>
  def symbol?: () -> _Schema<Symbol?>
  def array: <'x> (_Schema<'x>) -> _Schema<Array<'x>>
           | () -> _Schema<Array<any>>
  def array?: <'x> (_Schema<'x>) -> _Schema<Array<'x>?>
  def literal: <'x> ('x) -> _Schema<'x>
  def literal?: <'x> ('x) -> _Schema<'x?>
  def enum: <'x> (*_Schema<any>) -> _Schema<'x>
  def enum?: <'x> (*_Schema<any>) -> _Schema<'x?>
  def ignored: () -> _Schema<nil>
  def prohibited: () -> _Schema<nil>
end
