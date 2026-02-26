require "../../spec_helper"

describe Pipewire::SPA::ParamInfo do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::SPA::ParamInfo.new(Pointer(Pipewire::LibSPA::ParamInfo).null) }
    end
  end
end
