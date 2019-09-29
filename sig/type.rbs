module StrongJSON::Type
end

module StrongJSON::Type::Match : _Schema[any]
  def =~: (any) -> bool
  def ===: (any) -> bool
end

module StrongJSON::Type::WithAlias : ::Object
  @alias: Symbol?
  def `alias`: -> Symbol?
  def with_alias: (Symbol) -> self
end

type StrongJSON::base_type_name = :any | :number | :string | :boolean | :numeric | :symbol | :integer

class StrongJSON::Type::Base[A]
  include Match
  include WithAlias

  attr_reader type: base_type_name

  def initialize: (base_type_name) -> any
  def test: (any) -> bool
  def coerce: (any, ?path: ErrorPath) -> A
end

class StrongJSON::Type::Optional[T]
  include Match
  include WithAlias

  attr_reader type: _Schema[T]

  def initialize: (_Schema[T]) -> any
  def coerce: (any, ?path: ErrorPath) -> (T | nil)
end

class StrongJSON::Type::Literal[T]
  include Match
  include WithAlias

  attr_reader value: T

  def initialize: (T) -> any
  def coerce: (any, ?path: ErrorPath) -> T
end

class StrongJSON::Type::Array[T]
  include Match
  include WithAlias

  attr_reader type: _Schema[T]

  def initialize: (_Schema[T]) -> any
  def coerce: (any, ?path: ErrorPath) -> ::Array[T]
end

class StrongJSON::Type::Object[T]
  include Match
  include WithAlias

  attr_reader fields: ::Hash[Symbol, _Schema[any]]
  attr_reader on_unknown: :ignore | :reject
  attr_reader exceptions: Set[Symbol]

  def initialize: (::Hash[Symbol, _Schema[T]], on_unknown: :ignore | :reject, exceptions: Set[Symbol]) -> any
  def coerce: (any, ?path: ErrorPath) -> T

  # If no argument is given, it ignores all unknown attributes.
  # If `Symbol`s are given, it ignores the listed attributes, but rejects if other unknown attributes are detected.
  # If `except:` is specified, it rejects attributes listed in `except` are detected, but ignores other unknown attributes.
  def ignore: () -> Object[T]
            | (*Symbol) -> Object[T]
            | (?except: Set[Symbol]) -> Object[T]

  # If no argument is given, it rejects on any unknown attribute.
  # If `Symbol`s are given, it rejects the listed attributes are detected, but ignores other unknown attributes.
  # If `except:` is specified, it ignores given attributes, but rejects if other unknown attributes are detected.
  def reject: () -> Object[T]
            | (*Symbol) -> Object[T]
            | (?except: Set[Symbol]) -> Object[T]

  def update_fields: [X] { (::Hash[Symbol, _Schema[any]]) -> void } -> Object[X]
end

type StrongJSON::Type::detector = ^(any) -> _Schema[any]?

class StrongJSON::Type::Enum[T]
  include Match
  include WithAlias

  attr_reader types: ::Array[_Schema[any]]
  attr_reader detector: detector?

  def initialize: (::Array[_Schema[any]], ?detector?) -> any
  def coerce: (any, ?path: ErrorPath) -> T
end

class StrongJSON::Type::ErrorPath
  attr_reader type: _Schema[any]
  attr_reader parent: [Symbol | Integer | nil, ErrorPath]?

  def initialize: (type: _Schema[any], parent: [Symbol | Integer | nil, ErrorPath]?) -> any
  def dig: (key: Symbol | Integer, type: _Schema[any]) -> ErrorPath
  def expand: (type: _Schema[any]) -> ErrorPath

  def self.root: (_Schema[any]) -> ErrorPath
  def root?: -> bool
end

class StrongJSON::Type::TypeError < StandardError
  attr_reader path: ErrorPath
  attr_reader value: any

  def initialize: (path: ErrorPath, value: any) -> any
  def type: -> _Schema[any]
end

class StrongJSON::Type::UnexpectedAttributeError < StandardError
  attr_reader path: ErrorPath
  attr_reader attribute: Symbol

  def initialize: (path: ErrorPath, attribute: Symbol) -> any
  def type: -> _Schema[any]
end

class StrongJSON::Type::Hash[T]
  include Match
  include WithAlias

  attr_reader type: _Schema[T]

  def initialize: (_Schema[T]) -> any
  def coerce: (any, ?path: ErrorPath) -> ::Hash[Symbol, T]
end
