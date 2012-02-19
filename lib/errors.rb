module Travis
  module WebLint

    class Error < StandardError

      def type?(type)
        self.type == type
      end

      def type; end

    end

    class HTTPError   < Error; def type; :http end end
    class JSONError   < Error; def type; :json end end
    class YAMLError   < Error; def type; :yaml end end
    class LintError   < Error; def type; :lint end end
    class GithubError < Error; def type; :github end end

  end
end
