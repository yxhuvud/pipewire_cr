require "../spec_helper"

describe Pipewire::ThreadLoop do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::ThreadLoop.new(Pointer(Pipewire::LibPipewire::ThreadLoop).null) }
    end
  end
end
