require "net/http"
require File.expand_path("lib/result")
require File.expand_path("lib/errors")

module Travis
  module WebLint
    module Validator
      extend self

      SHA_URI = "http://github.com/api/v2/json/commits/list/%s/master"
      BLOB_URI = "http://github.com/api/v2/json/blob/show/%s/%s/.travis.yml"

      def validate_repo(repo)
        sha = get_sha(repo)
        travis_blob = get_blob(repo, sha)
        validate_yml(travis_blob)
      end

      def validate_yml(yml)
        travis_yml = yaml_load(yml)
        validate lint(travis_yml)
      end

    private

      def get_sha(repo)
        result = github_request(SHA_URI % repo)
        result["commits"].first["tree"]
      end

      def get_blob(repo, sha)
        result = github_request(BLOB_URI % [repo, sha])
        result["blob"]["data"]
      end

      def github_request(url)
        response = http_get(url).body
        result = json_parse(response)

        raise GithubError, result["error"] if result["error"]
        result
      end

      def http_get(url)
        Net::HTTP.get_response URI(url)
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

      def validate(issues)
        return Result.new(:invalid, issues) unless issues.empty?
        Result.new(:valid)
      end

      def lint(travis_yml)
        Lint::Linter.validate(travis_yml)
      rescue NoMethodError => e
        puts "LINT-ERROR #{e}"
        raise LintError
      end

    end
  end
end
