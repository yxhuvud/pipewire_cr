require "../spec_helper"

describe Pipewire::Properties do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::Properties.new(Pointer(Pipewire::LibPipewire::Properties).null) }
    end
  end
end
