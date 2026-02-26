require "../../spec_helper"

describe Pipewire::SPA::Pod do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(Pipewire::NullPointerError) { Pipewire::SPA::Pod.new(Pointer(Pipewire::LibSPA::Pod).null) }
    end
  end
end
