require "../spec_helper"

describe Pipewire::Registry do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::Registry.new(Pointer(Pipewire::LibPipewire::Registry).null) }
    end
  end
end
