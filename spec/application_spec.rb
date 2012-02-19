require "spec_helper"

ENV["RACK_ENV"] = "test"
require File.expand_path("../../application", __FILE__)

describe Travis::WebLint::Application do
  include Rack::Test::Methods

  def app
    Travis::WebLint::Application
  end

  describe "/" do
    before do
      get "/"
    end

    it "works" do
      last_response.should be_ok
    end

    it "contains a 'repo' input field" do
      last_response.body.should =~ /<input.*name='repo'.*?\/>/
    end

    it "contains a 'yml' textarea" do
      last_response.body.should =~ /<textarea.*name='yml'.*?>/
    end
  end

end
