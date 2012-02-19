require "spec_helper"

describe Travis::WebLint::Error do

  it "HTTPError is of type :http" do
    Travis::WebLint::HTTPError.new.should be_type(:http)
  end

  it "JSONError is of type :json" do
    Travis::WebLint::JSONError.new.should be_type(:json)
  end

  it "YAMLError is of type :http" do
    Travis::WebLint::YAMLError.new.should be_type(:yaml)
  end

  it "LintError is of type :lint" do
    Travis::WebLint::LintError.new.should be_type(:lint)
  end

  it "GithubError is of type :github" do
    Travis::WebLint::GithubError.new.should be_type(:github)
  end

end
