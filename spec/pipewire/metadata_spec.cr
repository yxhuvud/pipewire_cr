require "../spec_helper"

describe Pipewire::Metadata do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::Metadata.new(Pointer(Pipewire::LibPipewire::Metadata).null) }
    end
  end
end
