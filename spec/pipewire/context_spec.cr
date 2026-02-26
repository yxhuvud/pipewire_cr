require "../spec_helper"

describe Pipewire::Context do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::Context.new(Pointer(Pipewire::LibPipewire::Context).null) }
    end
  end
end
