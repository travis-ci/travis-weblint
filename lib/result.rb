module LintApp
  Result = Struct.new(:type, :issues) do

    def valid?
      type == :valid
    end

    def to_json
      if valid?
        { :valid => true }.to_json
      else
        { :valid => false, :issues => issues }.to_json
      end
    end

  end
end
