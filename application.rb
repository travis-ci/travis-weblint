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
          if params["sha"]
            redirect to("/#{params['repo']}/commit/#{params["sha"]}")
          elsif params["branch"]
            redirect to("/#{params['repo']}/tree/#{params["branch"]}")
          else
            redirect to("/#{params['repo']}")
          end
        elsif params["yml"]
          @result = Validator.validate_yml(params["yml"])
          haml :result
        end
      end

      get "/*" do
        parts = params["splat"].first.split("/")
        repo = parts[0..1].join("/")
        options = {}
        options[:sha] = parts[3] if parts[2] == "commit"
        options[:branch] = parts[3] if parts[2] == "tree"
        @result = Validator.validate_repo(repo, options)

        haml :result
      end

      error do
        @error = env["sinatra.error"]
        haml :error
      end

    end
  end
end
