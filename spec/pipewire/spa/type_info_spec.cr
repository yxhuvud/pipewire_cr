require "../../spec_helper"

describe Pipewire::SPA::TypeInfoList do
  describe ".new" do
    it "does not raise when receiving a null pointer" do
      Pipewire::SPA::TypeInfoList.new(Pointer(Pipewire::LibSPA::TypeInfo).null).should be_a Pipewire::SPA::TypeInfoList
    end
  end

  describe "#each" do
    it "succeeds when @pointer is a null pointer" do
      c = 0
      Pipewire::SPA::TypeInfoList.new(Pointer(Pipewire::LibSPA::TypeInfo).null).each { c += 1 }
      c.should eq 0
    end
  end

  describe ".root" do
    it "returns an instance with a pointer to each type info" do
      Pipewire::SPA::TypeInfoList.root.size.should eq 47
    end
  end
end

describe Pipewire::SPA::TypeInfo do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::SPA::TypeInfo.new(Pointer(Pipewire::LibSPA::TypeInfo).null) }
    end
  end

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
