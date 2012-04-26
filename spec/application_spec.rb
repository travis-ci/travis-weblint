require "spec_helper"

ENV["RACK_ENV"] = "test"
require File.expand_path("../../application", __FILE__)

describe Travis::WebLint::Application do
  include Rack::Test::Methods

  def app
    Travis::WebLint::Application
  end

  describe "GET /" do
    before do
      get "/"
    end

    it "works" do
      last_response.should be_ok
    end

    it "contains a 'repo' input field" do
      last_response.body.should =~ /<input.*name='repo'.*?\/>/
    end

    it "contains a 'sha' input field" do
      last_response.body.should =~ /<input.*name='sha'.*?\/>/
    end

    it "contains a 'branch' input field" do
      last_response.body.should =~ /<input.*name='branch'.*?\/>/
    end

    it "contains a 'yml' textarea" do
      last_response.body.should =~ /<textarea.*name='yml'.*?>/
    end
  end

  describe "POST /" do
    it "redirects to validate a given repo" do
      post "/", "repo" => "travis-ci/travis-ci"

      last_response.should be_redirect
      follow_redirect!
      last_request.url.should == "http://example.org/travis-ci/travis-ci"
    end

    it "redirects to validate a given repo with SHA" do
      post "/", "repo" => "travis-ci/travis-ci", "sha" => "b7fbb8b3479f118c1682271014503b1255a8ba02"

      last_response.should be_redirect
      follow_redirect!
      last_request.url.should == "http://example.org/travis-ci/travis-ci/commit/b7fbb8b3479f118c1682271014503b1255a8ba02"
    end

    it "redirects to validate a given repo with branch" do
      post "/", "repo" => "travis-ci/travis-ci", "branch" => "production"

      last_response.should be_redirect
      follow_redirect!
      last_request.url.should == "http://example.org/travis-ci/travis-ci/tree/production"
    end

    it "validates a given .travis.yml" do
      travis_yml = "language: ruby\nrvm:\n  - 1.9.3"
      validator.expects(:validate_yml).with(travis_yml).returns(result(:valid))

      post "/", "yml" => travis_yml
      last_response.body.should include("Hooray")
    end
  end

  describe "GET /*" do
    context "with a valid .travis.yml" do
      it "let's you know that your config is valid" do
        validator.stubs(:validate_repo).returns(result(:valid))

        get "/travis-ci/travis-ci"
        last_response.body.should include("Hooray")
      end
    end

    context "with an invalid .travis.yml" do
      it "displays the validation errors" do
        issues = [{ :key => :language, :issue => 'The "language" key is mandatory' }]
        validator.stubs(:validate_repo).returns(result(:invalid, issues))

        get "/travis-ci/travis-ci"
        last_response.body.should include('The "language" key is mandatory')
      end
    end

    it "works for regular repo names" do
      validator.expects(:validate_repo).with("travis-ci/travis-ci", {}).returns(result(:valid))

      get "/travis-ci/travis-ci"
      last_response.should be_ok
    end

    it "works for regular repo name and SHA" do
      validator.expects(:validate_repo).with("travis-ci/travis-ci", {:sha => "b7fbb8b3479f118c1682271014503b1255a8ba02"}).returns(result(:valid))

      get "/travis-ci/travis-ci/commit/b7fbb8b3479f118c1682271014503b1255a8ba02"
      last_response.should be_ok
    end

    it "works for regular repo name and branch" do
      validator.expects(:validate_repo).with("travis-ci/travis-ci", {:branch => "production"}).returns(result(:valid))

      get "/travis-ci/travis-ci/tree/production"
      last_response.should be_ok
    end

    it "works for repo names including a dot" do
      validator.expects(:validate_repo).with("koraktor/braumeister.org", {}).returns(result(:valid))

      get "/koraktor/braumeister.org"
      last_response.should be_ok
    end
  end

  def validator
    Travis::WebLint::Validator
  end

  def result(*args)
    Travis::WebLint::Result.new(*args)
  end

end
