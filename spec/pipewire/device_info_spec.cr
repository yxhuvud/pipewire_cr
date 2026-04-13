require "../spec_helper"

describe Pipewire::DeviceInfo do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::DeviceInfo.new(Pointer(Pipewire::LibPipewire::DeviceInfo).null) }
    end
  end
end
