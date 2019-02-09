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
  def coerce: (any, ?path: ErrorPath) -> 'a
end

class StrongJSON::Type::Optional<'t>
  include Match

  @type: _Schema<'t>

  def initialize: (_Schema<'t>) -> any
  def coerce: (any, ?path: ErrorPath) -> ('t | nil)
end

class StrongJSON::Type::Literal<'t>
  include Match

  attr_reader value: 't

  def initialize: ('t) -> any
  def coerce: (any, ?path: ErrorPath) -> 't
end

class StrongJSON::Type::Array<'t>
  include Match

  @type: _Schema<'t>

  def initialize: (_Schema<'t>) -> any
  def coerce: (any, ?path: ErrorPath) -> ::Array<'t>
end

class StrongJSON::Type::Object<'t>
  include Match

  @fields: Hash<Symbol, _Schema<'t>>

  def initialize: (Hash<Symbol, _Schema<'t>>) -> any
  def coerce: (any, ?path: ErrorPath) -> 't
  def test_value_type: <'x, 'y> (ErrorPath, _Schema<'x>, any) { ('x) -> 'y } -> 'y
  def merge: (Object<any> | Hash<Symbol, _Schema<any>>) -> Object<any>
  def except: (*Symbol) -> Object<any>
end

type StrongJSON::Type::detector = ^(any) -> _Schema<any>?

class StrongJSON::Type::Enum<'t>
  include Match

  attr_reader types: ::Array<_Schema<any>>
  attr_reader detector: detector?

  def initialize: (::Array<_Schema<any>>, ?detector?) -> any
  def coerce: (any, ?path: ErrorPath) -> 't
end

class StrongJSON::Type::ErrorPath
  attr_reader type: _Schema<any>
  attr_reader parent: [Symbol | Integer | nil, instance]?

  def initialize: (type: _Schema<any>, parent: [Symbol | Integer | nil, instance]?) -> any
  def (constructor) dig: (key: Symbol | Integer, type: _Schema<any>) -> self
  def (constructor) expand: (type: _Schema<any>) -> self

  def self.root: (_Schema<any>) -> instance
  def root?: -> bool
end

class StrongJSON::Type::TypeError < StandardError
  attr_reader path: ErrorPath
  attr_reader value: any

  def initialize: (path: ErrorPath, value: any) -> any
  def type: -> _Schema<any>
end

class StrongJSON::Type::UnexpectedAttributeError < StandardError
  attr_reader path: ErrorPath
  attr_reader attribute: Symbol

  def initialize: (path: ErrorPath, attribute: Symbol) -> any
  def type: -> _Schema<any>
end

class StrongJSON::Type::IllegalTopTypeError < StandardError
  attr_reader type: ty
  def initialize: (type: ty) -> any
end
