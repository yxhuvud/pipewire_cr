require "../spec_helper"

describe Pipewire::Loop do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::Loop.new(Pointer(Pipewire::LibPipewire::Loop).null) }
    end
  end
end
