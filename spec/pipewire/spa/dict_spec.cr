require "../../spec_helper"

describe Pipewire::SPA::Dict do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::SPA::Dict.new(Pointer(Pipewire::LibSPA::Dict).null) }
    end
  end
end
