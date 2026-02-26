require "../../spec_helper"

describe Pipewire::SPA::Buffer do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::SPA::Buffer.new(Pointer(Pipewire::LibSPA::Buffer).null) }
    end
  end
end
