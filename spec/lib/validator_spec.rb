require "spec_helper"

describe Travis::WebLint::Validator do

  describe ".validate_repo" do
    it "returns a valid result for a valid config" do
      mock_http_requests_with_valid_config
      mock_linter_with_valid_config

      result = Travis::WebLint::Validator.validate_repo("travis-ci/travis-ci")
      result.should be_valid
    end

    it "returns an invalid result for an invalid config" do
      mock_http_requests_with_invalid_config
      mock_linter_with_invalid_config

      result = Travis::WebLint::Validator.validate_repo("travis-ci/travis-ci")
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

  def mock_http_requests_with_valid_config
    http_sequence = mock_http_sha_request

    blob_response = mock(:body => '{ "blob": { "data": "language: ruby\nrvm:\n  - 1.9.3" } }')
    Net::HTTP.expects(:get_response).returns(blob_response).in_sequence(http_sequence)
  end

  def mock_http_requests_with_invalid_config
    http_sequence = mock_http_sha_request

    blob_response = mock(:body => '{ "blob": { "data": "rvm:\n  - 1.9.3" } }')
    Net::HTTP.expects(:get_response).returns(blob_response).in_sequence(http_sequence)
  end

  def mock_http_sha_request
    http_sequence = sequence("http_requests")

    sha_response = mock(:body => '{ "commits": [{ "tree": "b7fbb8b3479f118c1682271014503b1255a8ba02" }] }')
    Net::HTTP.expects(:get_response).returns(sha_response).in_sequence(http_sequence)

    http_sequence
  end

  def mock_linter_with_valid_config
    Travis::Lint::Linter.expects(:validate).with("language" => "ruby", "rvm" => ["1.9.3"]).returns([])
  end

  def mock_linter_with_invalid_config
    Travis::Lint::Linter.expects(:validate).with("rvm" => ["1.9.3"]).
      returns([{ :key => :language, :issue => 'The "language" key is mandatory' }])
  end

end
