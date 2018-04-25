require 'chain_control/version'
require 'chain_control/base'
require 'chain_control/function'

module ChainControl
  def self.instance(target = nil, options = {})
    ChainControl::Base.new(target, options)
  end
end
