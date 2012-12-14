require "net/https"
require "base64"

require File.expand_path("lib/result")
require File.expand_path("lib/errors")

module Travis
  module WebLint
    module Validator
      extend self

      API_HOST = 'api.github.com'
      API_PORT = 443

      SHA_PATH  = "/repos/%s/commits"
      BLOB_PATH = "/repos/%s/contents/.travis.yml?sha=%s"

      def validate_repo(repo, options = {})
        sha = options[:sha] || get_sha(repo, options[:branch] || "master")
        travis_blob = get_blob(repo, sha)
        validate_yml(travis_blob)
      end

      def validate_yml(yml)
        travis_yml = yaml_load(yml)
        validate lint(travis_yml)
      end

    private

      def get_sha(repo, branch)
        result = github_request(SHA_PATH % [repo, branch])
        result.first["sha"]
      end

      def get_blob(repo, sha)
        Base64.decode64(github_request(BLOB_PATH % [repo, sha])["content"])
      end

      def github_request(path)
        json_parse(https_get(path).body)
      end

      def https_get(path)
        https = Net::HTTP.new(API_HOST, API_PORT)
        https.use_ssl = true

        response = https.get(path)

        if response.is_a?(Net::HTTPOK)
          response
        else
          raise HTTPError
        end
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
