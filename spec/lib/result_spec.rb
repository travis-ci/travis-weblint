require "spec_helper"

describe Travis::WebLint::Result do

  describe "a valid result" do
    subject do
      Travis::WebLint::Result.new(:valid)
    end

    it "is valid" do
      subject.should be_valid
    end
  end

  describe "an invalid result" do
    subject do
      Travis::WebLint::Result.new(:invalid, issues)
    end

    let(:issues) do
      [{ :key => :language, :issue => 'The "language" key is mandatory' }]
    end

    it "is not valid" do
      subject.should_not be_valid
    end

    it "contains a list of validation errors" do
      subject.issues.should == issues
    end
  end

end
