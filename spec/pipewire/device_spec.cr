require "../spec_helper"

describe Pipewire::Device do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::Device.new(Pointer(Pipewire::LibPipewire::Device).null) }
    end
  end
end
