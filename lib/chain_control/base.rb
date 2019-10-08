module ChainControl
  class Base
    attr_reader :target, :options

    def initialize(target, options = {})
      @target = target
      @options = options || {}
    end

    def add(validation, operation, args = {})
      values = args.nil? ? options : options.merge(args)
      add_function(validation, operation, values)
      self
    end

    def execute
      function&.handler || options.fetch(:default, nil)
    end

    def []=(validation, operation)
      add(validation, operation)
    end

    def size
      function&.level || 0
    end

    private

    attr_accessor :function

    def add_function(validation, operation, args)
      func = Function.new(target, validation, operation, args)
      (self.function = func) && return if function.nil?

      function.add_successor func
    end
  end
end
