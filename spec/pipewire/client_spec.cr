require "../spec_helper"

describe Pipewire::Client do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::Client.new(Pointer(Pipewire::LibPipewire::Client).null) }
    end
  end
end
