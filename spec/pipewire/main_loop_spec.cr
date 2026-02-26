require "../spec_helper"

describe Pipewire::MainLoop do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::MainLoop.new(Pointer(Pipewire::LibPipewire::MainLoop).null) }
    end
  end
end
