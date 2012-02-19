require "net/http"
require File.expand_path("lib/result")

module Travis
  module WebLint
    module Validator
      extend self

      class Error < StandardError; end
      class HTTPError < Error; end
      class JSONError < Error; end
      class YAMLError < Error; end
      class GithubError < Error; end

      SHA_URI = "http://github.com/api/v2/json/commits/list/%s/master"
      BLOB_URI = "http://github.com/api/v2/json/blob/show/%s/%s/.travis.yml"

      def validate_repo(repo)
        sha = get_sha(repo)
        travis_blob = get_blob(repo, sha)
        validate_yml(travis_blob)
      end

      def validate_yml(yml)
        lint yaml_load(yml)
      end

    private

      def get_sha(repo)
        response = http_get(SHA_URI, repo).body
        result = json_parse(response)

        raise GithubError, result["error"] if result["error"]
        result["commits"].first["tree"]
      end

      def get_blob(repo, sha)
        response = http_get(BLOB_URI, repo, sha).body
        result = json_parse(response)
        result["blob"]["data"]
      end

      def http_get(uri, *args)
        Net::HTTP.get_response URI(uri % args)
      rescue SocketError
        raise HTTPError
      end

      def json_parse(string)
        JSON.parse(string)
      rescue JSON::ParserError
        raise JSONError
      end

      def yaml_load(string)
        YAML.load(string)
      rescue ArgumentError, Psych::SyntaxError
        raise YAMLError
      end

      def lint(travis_yml)
        issues = Lint::Linter.validate(travis_yml)

        return Result.new(:invalid, issues) unless issues.empty?
        Result.new(:valid)
      end

    end
  end
end
