require "../../spec_helper"

describe Pipewire::SPA::TypeInfoList do
  describe ".root" do
    it "returns an instance with a pointer to each type info" do
      Pipewire::SPA::TypeInfoList.root.size.should eq 47
    end
  end
end

describe Pipewire::SPA::TypeInfo do
  describe "#type" do
    it "returns a value" do
      Pipewire::SPA::TypeInfoList.root[1].type.should eq 1
    end
  end

  describe "#parent" do
    it "returns a value" do
      Pipewire::SPA::TypeInfoList.root[1].parent.should eq 1
    end
  end

  describe "#name" do
    it "returns a value" do
      Pipewire::SPA::TypeInfoList.root[1].name.should eq "Spa:None"
    end
  end

  describe "#values" do
    it "returns a value" do
      Pipewire::SPA::TypeInfoList.root[1].values.size.should eq 0
    end
  end

  describe "#short_name" do
    it "returns a shortened name" do
      Pipewire::SPA::TypeInfoList.root[1].short_name.should eq "None"
    end
  end
end
