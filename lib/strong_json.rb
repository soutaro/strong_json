require "strong_json/version"
require "strong_json/type"
require "strong_json/types"

class StrongJSON
  def initialize(&block)
    instance_eval(&block)
  end

  def let(name, type)
    define_singleton_method(name) { type.with_alias(name) }
  end

  include StrongJSON::Types
end
