require "bundler"
Bundler.require

require File.expand_path("lib/validator")

module Travis
  module WebLint
    class Application < Sinatra::Base

      configure :production do
        disable :raise_errors
        disable :show_exceptions

        set :haml, :ugly => true
        set :sass, :style => :compressed
      end

      get "/style.css" do
        sass :style
      end

      get "/" do
        haml :index
      end

      post "/" do
        if params["repo"]
          redirect to("/#{params['repo']}/#{params['sha']}")
        elsif params["yml"]
          @result = Validator.validate_yml(params["yml"])
          haml :result
        end
      end

      get "/:user/:repo/:sha?" do
        repo = "#{params['user']}/#{params['repo']}"
        sha = params["sha"] || "master"
        @result = Validator.validate_repo(repo, sha)

        haml :result
      end

      get "/*" do
        repo = params["splat"].first
        @result = Validator.validate_repo(repo, "master")

        haml :result
      end

      error do
        @error = env["sinatra.error"]
        haml :error
      end

    end
  end
end
