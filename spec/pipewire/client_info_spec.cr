require "../spec_helper"

describe Pipewire::ClientInfo do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::ClientInfo.new(Pointer(Pipewire::LibPipewire::ClientInfo).null) }
    end
  end
end
