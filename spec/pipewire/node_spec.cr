require "../spec_helper"

describe Pipewire::Node do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::Node.new(Pointer(Pipewire::LibPipewire::Node).null) }
    end
  end
end
