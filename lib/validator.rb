require "net/http"
require File.expand_path("lib/result")

module LintApp
  module Validator
    extend self

    class Error < StandardError; end
    class HTTPError < Error; end
    class JSONError < Error; end
    class YAMLError < Error; end
    class GithubError < Error; end

    SHA_URI = "http://github.com/api/v2/json/commits/list/%s/master"
    BLOB_URI = "http://github.com/api/v2/json/blob/show/%s/%s/.travis.yml"

    def validate(project)
      sha = get_sha(project)
      travis_blob = get_blob(project, sha)
      lint yaml_load(travis_blob)
    end

  private

    def get_sha(project)
      response = http_get(SHA_URI, project).body
      result = json_parse(response)

      raise GithubError, result["error"] if result["error"]
      result["commits"].first["tree"]
    end

    def get_blob(project, sha)
      response = http_get(BLOB_URI, project, sha).body
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
      issues = Travis::Lint::Linter.validate(travis_yml)

      return Result.new(:issues, issues) unless issues.empty?
      Result.new(:valid)
    end

  end
end
