require "base64"
require "spec_helper"

describe Travis::WebLint::Validator do

  describe ".validate_repo" do
    it "returns a valid result for a valid config" do
      mock_https_requests_with_valid_config
      mock_linter_with_valid_config

      result = Travis::WebLint::Validator.validate_repo("travis-ci/travis-ci", "master")
      result.should be_valid
    end

    it "returns an invalid result for an invalid config" do
      mock_https_requests_with_invalid_config
      mock_linter_with_invalid_config

      result = Travis::WebLint::Validator.validate_repo("travis-ci/travis-ci", "master")
      result.should_not be_valid
    end
  end

  describe ".validate_yml" do
    it "returns a valid result for a valid config" do
      mock_linter_with_valid_config

      result = Travis::WebLint::Validator.validate_yml("language: ruby\nrvm:\n  - 1.9.3")
      result.should be_valid
    end

    it "returns an invalid result for an invalid config" do
      mock_linter_with_invalid_config

      result = Travis::WebLint::Validator.validate_yml("rvm:\n  - 1.9.3")
      result.should_not be_valid
    end
  end

  def mock_https_requests_with_valid_config
    mock_https_get(blob_content("language: ruby\nrvm:\n  - 1.9.3"))
  end

  def mock_https_requests_with_invalid_config
    mock_https_get(blob_content("rvm:\n  - 1.9.3"))
  end

  def blob_content(string)
    %Q({ "content": "#{Base64.encode64(string).gsub(/\n/, '\\n')}" })
  end

  def mock_https_get(response_body)
    https = Object.new

    Net::HTTP.expects(:new).with('api.github.com', 443).returns(https)
    https.expects(:use_ssl=).with(true)
    https.expects(:get).returns(response_with_body(response_body))
  end

  def response_with_body(body)
    response = Net::HTTPOK.new("1.1", "200", "OK")
    response.stubs(:body).returns(body)
    response
  end

  def mock_linter_with_valid_config
    Travis::Lint::Linter.expects(:validate).with("language" => "ruby", "rvm" => ["1.9.3"]).returns([])
  end

  def mock_linter_with_invalid_config
    Travis::Lint::Linter.expects(:validate).with("rvm" => ["1.9.3"]).
      returns([{ :key => :language, :issue => 'The "language" key is mandatory' }])
  end

end
