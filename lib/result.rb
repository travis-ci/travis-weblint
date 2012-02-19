module Travis
  module WebLint
    class Result

      TYPES = [:valid, :invalid]

      def initialize(type, issues = nil)
        self.type = type
        self.issues = issues
      end

      attr_reader :type

      def type=(type)
        raise ArgumentError, "Invalid result type" unless TYPES.include?(type)
        @type = type
      end

      attr_accessor :issues

      def valid?
        type == :valid
      end

    end
  end
end
