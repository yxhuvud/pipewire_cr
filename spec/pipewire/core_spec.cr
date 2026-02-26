require "../spec_helper"

describe Pipewire::Core do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::Core.new(Pointer(Pipewire::LibPipewire::Core).null) }
    end
  end
end
