require "./examples_helper"

describe "Example scripts" do
  example_scripts.each do |name|
    describe name do
      it "compiles" do
        File.exists?(example_executable!(name)).should eq true
      end
    end
  end
end
