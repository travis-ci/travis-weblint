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

    it "contains a 'yml' textarea" do
      last_response.body.should =~ /<textarea.*name='yml'.*?>/
    end
  end

  describe "POST /" do
    it "redirects to validate a given repo" do
      post "/", "repo" => "travis-ci/travis-ci"

      last_response.should be_redirect
      last_response.location.should == "http://example.org/travis-ci/travis-ci/"
    end

    it "redirects to validate a given repo and branch" do
      post "/", "repo" => "travis-ci/travis-ci", "sha" => "master"

      last_response.should be_redirect
      last_response.location.should == "http://example.org/travis-ci/travis-ci/master"
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
      it "lets you know that your config is valid" do
        validator.stubs(:validate_repo).returns(result(:valid))

        get "/travis-ci/travis-ci"
        last_response.body.should include("Hooray")
      end

      it "lets you know that your config is valid for a given branch" do
        validator.stubs(:validate_repo).returns(result(:valid))

        get "/travis-ci/travis-ci/foo"
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

      it "displays the validation errors for a given branch" do
        issues = [{ :key => :language, :issue => 'The "language" key is mandatory' }]
        validator.stubs(:validate_repo).returns(result(:invalid, issues))

        get "/travis-ci/travis-ci/foo"
        last_response.body.should include('The "language" key is mandatory')
      end
    end

    it "works for regular repo names" do
      validator.expects(:validate_repo).with("travis-ci/travis-ci", "master").returns(result(:valid))

      get "/travis-ci/travis-ci"
      last_response.should be_ok
    end

    it "works for repo names including a dot" do
      validator.expects(:validate_repo).with("koraktor/braumeister.org", "master").returns(result(:valid))

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
