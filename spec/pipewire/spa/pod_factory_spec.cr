require "../../spec_helper"

private def u32(to_slice, offset)
  IO::ByteFormat::LittleEndian.decode(UInt32, to_slice[offset, 4])
end

private def aligned8?(to_slice)
  to_slice.size % 8 == 0
end

describe Pipewire::SPA::PodFactory do
  describe "primitive pods" do
    it "builds int pod" do
      pod = Pipewire::SPA::PodFactory.new
      pod.int(42)

      to_slice = pod.to_slice

      u32(to_slice, 0).should eq(4) # size
      u32(to_slice, 4).should eq(Pipewire::LibSPA::PodType::Int.value)
      u32(to_slice, 8).should eq(42)

      aligned8?(to_slice).should be_true
    end

    it "builds bool pod" do
      pod = Pipewire::SPA::PodFactory.new
      pod.bool(true)

      to_slice = pod.to_slice

      u32(to_slice, 8).should eq(1)
      aligned8?(to_slice).should be_true
    end

    it "builds id pod" do
      pod = Pipewire::SPA::PodFactory.new
      pod.id(7)

      to_slice = pod.to_slice

      u32(to_slice, 8).should eq(7)
      aligned8?(to_slice).should be_true
    end

    it "builds string pod (null terminated)" do
      pod = Pipewire::SPA::PodFactory.new
      pod.string("abc")

      to_slice = pod.to_slice

      size = u32(to_slice, 0)
      size.should eq(4) # "abc\0"

      to_slice[8, 4].should eq(Bytes[97, 98, 99, 0])

      aligned8?(to_slice).should be_true
    end
  end

  describe "object pods" do
    it "builds empty object" do
      pod = Pipewire::SPA::PodFactory.new
      pod.object(
        Pipewire::LibSPA::PodObjectType::Format,
        Pipewire::LibSPA::ParamType::Invalid
      ) { }

      to_slice = pod.to_slice

      size = u32(to_slice, 0)
      size.should eq(8) # type + id only

      aligned8?(to_slice).should be_true
    end

    it "builds object with one property" do
      key = 123u32

      pod = Pipewire::SPA::PodFactory.new
      pod.object(
        Pipewire::LibSPA::PodObjectType::Format,
        Pipewire::LibSPA::ParamType::Invalid
      ) do
        pod.prop(key) do
          pod.int(55)
        end
      end

      to_slice = pod.to_slice

      # object header
      obj_size = u32(to_slice, 0)
      obj_type = u32(to_slice, 4)

      obj_type.should eq(Pipewire::LibSPA::PodType::Object.value)

      # object body starts at 8
      obj_body_size = obj_size
      obj_body_size.should be > 8

      # first prop key
      prop_offset = 8 + 8 # skip type + id
      u32(to_slice, prop_offset).should eq(key)

      aligned8?(to_slice).should be_true
    end
  end

  describe "properties" do
    it "writes key + flags + value" do
      key = 1u32

      pod = Pipewire::SPA::PodFactory.new
      pod.object(
        Pipewire::LibSPA::PodObjectType::Format,
        Pipewire::LibSPA::ParamType::Invalid
      ) do
        pod.prop(key) do
          pod.int(99)
        end
      end

      to_slice = pod.to_slice

      prop_offset = 16 # header (8) + obj type/id (8)

      u32(to_slice, prop_offset).should eq(key)   # key
      u32(to_slice, prop_offset + 4).should eq(0) # flags

      # value pod header follows
      u32(to_slice, prop_offset + 8).should eq(4) # size
    end

    it "allows flags" do
      key = 1u32
      flags = Pipewire::LibSPA::PropFlag::Readonly

      pod = Pipewire::SPA::PodFactory.new
      pod.object(
        Pipewire::LibSPA::PodObjectType::Format,
        Pipewire::LibSPA::ParamType::Invalid
      ) do
        pod.prop(key, flags) do
          pod.int(1)
        end
      end

      to_slice = pod.to_slice
      prop_offset = 16

      u32(to_slice, prop_offset + 4).should eq(flags.value)
    end
  end

  describe "alignment" do
    it "pads to 8 to_slice for multiple writes" do
      pod = Pipewire::SPA::PodFactory.new
      pod.string("a")
      pod.int(1)

      to_slice = pod.to_slice
      aligned8?(to_slice).should be_true
    end
  end

  describe "nesting" do
    it "supports nested objects" do
      pod = Pipewire::SPA::PodFactory.new
      pod.object(
        Pipewire::LibSPA::PodObjectType::Format,
        Pipewire::LibSPA::ParamType::Invalid
      ) do
        pod.prop(1u32) do
          pod.object(
            Pipewire::LibSPA::PodObjectType::Format,
            Pipewire::LibSPA::ParamType::Invalid
          ) { }
        end
      end

      to_slice = pod.to_slice
      aligned8?(to_slice).should be_true
    end
  end

  describe "determinism" do
    it "produces identical output for same input" do
      pod = Pipewire::SPA::PodFactory.new
      pod.int(5)
      a = pod.to_slice
      pod = Pipewire::SPA::PodFactory.new
      pod.int(5)
      b = pod.to_slice

      a.should eq(b)
    end
  end
end
