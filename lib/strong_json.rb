require "set"
require "strong_json/version"
require "strong_json/type"
require "strong_json/types"
require "strong_json/error_reporter"
require "prettyprint"

class StrongJSON
  def initialize(&block)
    instance_eval(&block)
  end

  def let(name, type)
    define_singleton_method(name) { type.with_alias(name) }
  end

  include StrongJSON::Types
end
