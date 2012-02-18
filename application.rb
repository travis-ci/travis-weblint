require "bundler"
Bundler.require

require File.expand_path("lib/validator")

module Travis
  module WebLint
    class Application < Sinatra::Base

      register Sinatra::RespondTo

      get "/" do
        haml :index
      end

      post "/" do
        redirect to("/#{params['repo']}")
      end

      get "/*" do
        repo = params["splat"].first
        @result = Validator.validate(repo)

        respond_to do |wants|
          wants.html { haml :result }
          wants.json { @result.to_json }
        end
      end

    end
  end
end
