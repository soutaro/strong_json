module StrongJSON::Type
end

StrongJSON::Type::NONE: any

module StrongJSON::Type::Match: _Schema<any>
  def =~: (any) -> bool
  def ===: (any) -> bool
end

type StrongJSON::base_type_name = :ignored | :any | :number | :string | :boolean | :numeric | :symbol | :prohibited

class StrongJSON::Type::Base<'a>
  include Match

  attr_reader type: base_type_name

  def initialize: (base_type_name) -> any
  def test: (any) -> bool
  def coerce: (any, ?path: ::Array<Symbol>) -> 'a
end

class StrongJSON::Type::Optional<'t>
  include Match

  @type: _Schema<'t>

  def initialize: (_Schema<'t>) -> any
  def coerce: (any, ?path: ::Array<Symbol>) -> ('t | nil)
end

class StrongJSON::Type::Literal<'t>
  include Match

  attr_reader value: 't

  def initialize: ('t) -> any
  def coerce: (any, ?path: ::Array<Symbol>) -> 't
end

class StrongJSON::Type::Array<'t>
  include Match

  @type: _Schema<'t>

  def initialize: (_Schema<'t>) -> any
  def coerce: (any, ?path: ::Array<Symbol>) -> ::Array<'t>
end

class StrongJSON::Type::Object<'t>
  include Match

  @fields: Hash<Symbol, _Schema<'t>>

  def initialize: (Hash<Symbol, _Schema<'t>>) -> any
  def coerce: (any, ?path: ::Array<Symbol>) -> 't
  def test_value_type: <'x, 'y> (::Array<Symbol>, _Schema<'x>, any) { ('x) -> 'y } -> 'y
  def merge: (Object<any> | Hash<Symbol, _Schema<any>>) -> Object<any>
  def except: (*Symbol) -> Object<any>
end

class StrongJSON::Type::Enum<'t>
  include Match

  attr_reader types: ::Array<_Schema<any>>

  def initialize: (::Array<_Schema<any>>) -> any
  def coerce: (any, ?path: ::Array<Symbol>) -> 't
end

class StrongJSON::Type::Error
  attr_reader path: ::Array<Symbol>
  attr_reader type: ty
  attr_reader value: any

  def initialize: (path: ::Array<Symbol>, type: ty, value: any) -> any
end

class StrongJSON::Type::UnexpectedFieldError
  attr_reader path: ::Array<Symbol>
  attr_reader value: any

  def initialize: (path: ::Array<Symbol>, value: any) -> any
end

class StrongJSON::Type::IllegalTypeError
  attr_reader type: ty
  def initialize: (type: ty) -> any
end
