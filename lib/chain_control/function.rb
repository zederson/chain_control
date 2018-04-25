module ChainControl
  class Function
    attr_reader :target, :validation, :operation, :options, :successor

    def initialize(target, validation, operation, options = {})
      @target = target
      @validation = validation
      @operation = operation
      @options = options
    end

    def applicable?
      execute(validation)
    end

    def handler
      @cache = nil unless use_cache?
      if applicable?
        @cache ||= execute(operation)
      else
        successor&.handler
      end
    end

    def add_successor(function)
      if successor
        successor.add_successor function
      else
        @successor = function
      end
    end

    def level
      if successor
        successor.level + 1
      else
        1
      end
    end

    private

    def use_cache?
      options[:cache]
    end

    def execute(operand)
      return target.send(operand) if symbol?(operand)
      return operand.call if callable?(operand)
      operand
    end

    def callable?(compare)
      compare.respond_to? :call
    end

    def symbol?(compare)
      compare.is_a? Symbol
    end
  end
end
