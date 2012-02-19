require "bundler"
Bundler.require

require File.expand_path("lib/validator")

module Travis
  module WebLint
    class Application < Sinatra::Base

      configure :production do
        set :raise_errors, false
        set :show_exceptions, false
      end

      get "/style.css" do
        sass :style
      end

      get "/" do
        haml :index
      end

      post "/" do
        if params['repo']
          redirect to("/#{params['repo']}")
        elsif params['yml']
          @result = Validator.validate_yml(params['yml'])
          haml :result
        end
      end

      get "/*" do
        repo = params["splat"].first
        @result = Validator.validate_repo(repo)

        haml :result
      end

      error do
        @error = env["sinatra.error"]
        haml :error
      end

    end
  end
end
