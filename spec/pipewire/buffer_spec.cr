require "../spec_helper"

describe Pipewire::Buffer do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::Buffer.new(Pointer(Pipewire::LibPipewire::Buffer).null) }
    end
  end
end
