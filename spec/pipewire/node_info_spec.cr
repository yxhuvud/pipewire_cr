require "../spec_helper"

describe Pipewire::NodeInfo do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::NodeInfo.new(Pointer(Pipewire::LibPipewire::NodeInfo).null) }
    end
  end
end
