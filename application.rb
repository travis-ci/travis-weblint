require "bundler"
Bundler.require

require File.expand_path("lib/validator")

module Travis
  module WebLint
    class Application < Sinatra::Base

      register Sinatra::RespondTo

      configure :production do
        set :raise_errors, false
        set :show_exceptions, false
      end

      get "/style" do
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

        respond_to do |wants|
          wants.html { haml :result }
          wants.json { @result.to_json }
        end
      end

      error do
        @error = env["sinatra.error"]
        haml :error
      end

    end
  end
end
