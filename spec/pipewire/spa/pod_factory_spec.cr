require "../../spec_helper"

private def u32(to_slice, offset)
  IO::ByteFormat::LittleEndian.decode(UInt32, to_slice[offset, 4])
end

private def f32(to_slice, offset)
  IO::ByteFormat::LittleEndian.decode(Float32, to_slice[offset, 4])
end

private def i64(to_slice, offset)
  IO::ByteFormat::LittleEndian.decode(Int64, to_slice[offset, 8])
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

    it "builds fraction pod" do
      pod = Pipewire::SPA::PodFactory.new
      pod.fraction(1, 2)

      to_slice = pod.to_slice

      u32(to_slice, 0).should eq(8) # size of num + denom
      u32(to_slice, 4).should eq(Pipewire::LibSPA::PodType::Fraction.value)
      u32(to_slice, 8).should eq(1)  # num
      u32(to_slice, 12).should eq(2) # denom

      aligned8?(to_slice).should be_true
    end

    it "builds rectangle pods" do
      pod = Pipewire::SPA::PodFactory.new
      pod.rectangle(100, 200)

      to_slice = pod.to_slice

      u32(to_slice, 0).should eq(8) # size of width + height
      u32(to_slice, 4).should eq(Pipewire::LibSPA::PodType::Rectangle.value)
      u32(to_slice, 8).should eq(100)  # width
      u32(to_slice, 12).should eq(200) # height

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

  describe "array pods" do
    it "builds int array pod" do
      pod = Pipewire::SPA::PodFactory.new
      pod.array([1, 2, 3])

      slice = pod.to_slice

      # header
      u32(slice, 0).should eq(8 + 3 * 4) # child header + 3 ints
      u32(slice, 4).should eq(Pipewire::LibSPA::PodType::Array.value)

      # child header
      u32(slice, 8).should eq(4) # element size
      u32(slice, 12).should eq(Pipewire::LibSPA::PodType::Int.value)

      # values
      u32(slice, 16).should eq(1)
      u32(slice, 20).should eq(2)
      u32(slice, 24).should eq(3)

      aligned8?(slice).should be_true
    end

    it "builds float32 array pod" do
      pod = Pipewire::SPA::PodFactory.new
      pod.array([1.0_f32, 2.5_f32])

      slice = pod.to_slice

      u32(slice, 0).should eq(8 + 2 * 4)
      u32(slice, 4).should eq(Pipewire::LibSPA::PodType::Array.value)

      u32(slice, 8).should eq(4)
      u32(slice, 12).should eq(Pipewire::LibSPA::PodType::Float.value)

      f32(slice, 16).should eq(1.0_f32)
      f32(slice, 20).should eq(2.5_f32)

      aligned8?(slice).should be_true
    end

    it "builds int64 array pod" do
      pod = Pipewire::SPA::PodFactory.new
      pod.array([1_i64, 2_i64])

      slice = pod.to_slice

      u32(slice, 0).should eq(8 + 2 * 8)
      u32(slice, 4).should eq(Pipewire::LibSPA::PodType::Array.value)

      u32(slice, 8).should eq(8)
      u32(slice, 12).should eq(Pipewire::LibSPA::PodType::Long.value)

      i64(slice, 16).should eq(1_i64)
      i64(slice, 24).should eq(2_i64)

      aligned8?(slice).should be_true
    end
  end

  describe "range pods" do
    it "builds int range pod" do
      pod = Pipewire::SPA::PodFactory.new
      pod.range(10, 0, 20)

      slice = pod.to_slice

      u32(slice, 0).should eq(28) # body size
      u32(slice, 4).should eq(Pipewire::LibSPA::PodType::Choice.value)

      u32(slice, 8).should eq(Pipewire::LibSPA::Choice::Range.value)
      u32(slice, 12).should eq(0) # flags

      u32(slice, 16).should eq(4)
      u32(slice, 20).should eq(Pipewire::LibSPA::PodType::Int.value)

      u32(slice, 24).should eq(10) # default
      u32(slice, 28).should eq(0)  # min
      u32(slice, 32).should eq(20) # max

      aligned8?(slice).should be_true
    end

    it "builds float32 range pod" do
      pod = Pipewire::SPA::PodFactory.new
      pod.range(0.5_f32, 0.0_f32, 1.0_f32)

      slice = pod.to_slice

      u32(slice, 0).should eq(28)
      u32(slice, 4).should eq(Pipewire::LibSPA::PodType::Choice.value)

      u32(slice, 8).should eq(Pipewire::LibSPA::Choice::Range.value)
      u32(slice, 12).should eq(0)

      u32(slice, 16).should eq(4)
      u32(slice, 20).should eq(Pipewire::LibSPA::PodType::Float.value)

      f32(slice, 24).should eq(0.5_f32)
      f32(slice, 28).should eq(0.0_f32)
      f32(slice, 32).should eq(1.0_f32)

      aligned8?(slice).should be_true
    end

    it "builds fraction range pod" do
      pod = Pipewire::SPA::PodFactory.new
      pod.range(
        Pipewire::SPA::PodFactory::Fraction.new(30, 1),
        Pipewire::SPA::PodFactory::Fraction.new(1, 1),
        Pipewire::SPA::PodFactory::Fraction.new(60, 1)
      )

      slice = pod.to_slice

      # pod header
      u32(slice, 0).should eq(40)
      u32(slice, 4).should eq(Pipewire::LibSPA::PodType::Choice.value)

      # choice header
      u32(slice, 8).should eq(Pipewire::LibSPA::Choice::Range.value)
      u32(slice, 12).should eq(0)

      # child header
      u32(slice, 16).should eq(8)
      u32(slice, 20).should eq(Pipewire::LibSPA::PodType::Fraction.value)

      u32(slice, 24).should eq(30)
      u32(slice, 28).should eq(1)

      u32(slice, 32).should eq(1)
      u32(slice, 36).should eq(1)

      u32(slice, 40).should eq(60)
      u32(slice, 44).should eq(1)

      aligned8?(slice).should be_true
    end
  end

  describe "enum pods" do
    it "builds enum choice pod (id)" do
      pod = Pipewire::SPA::PodFactory.new
      pod.choice_enum_id(Pipewire::LibSPA::AudioFormat::S16, [
        Pipewire::LibSPA::AudioFormat::S16_LE,
        Pipewire::LibSPA::AudioFormat::S16_BE,
        Pipewire::LibSPA::AudioFormat::S24_BE,
      ])

      slice = pod.to_slice

      # pod header
      u32(slice, 0).should eq(8 + 8 + 4 * 4) # 8 + 8 + 16 = 32
      u32(slice, 4).should eq(Pipewire::LibSPA::PodType::Choice.value)

      # choice header
      u32(slice, 8).should eq(Pipewire::LibSPA::Choice::Enum.value)
      u32(slice, 12).should eq(0)

      # child header
      u32(slice, 16).should eq(4)
      u32(slice, 20).should eq(Pipewire::LibSPA::PodType::Id.value)

      u32(slice, 24).should eq(Pipewire::LibSPA::AudioFormat::S16.value)
      u32(slice, 28).should eq(Pipewire::LibSPA::AudioFormat::S16_LE.value)
      u32(slice, 32).should eq(Pipewire::LibSPA::AudioFormat::S16_BE.value)
      u32(slice, 36).should eq(Pipewire::LibSPA::AudioFormat::S24_BE.value)

      aligned8?(slice).should be_true
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

  describe "struct pods" do
    it "builds struct pod" do
      pod = Pipewire::SPA::PodFactory.new
      pod.struct do
        pod.int(42)
        pod.string("hello")
      end

      to_slice = pod.to_slice

      # struct header
      u32(to_slice, 0).should eq(16 + 16)
      u32(to_slice, 4).should eq(Pipewire::LibSPA::PodType::Struct.value)

      # int value
      u32(to_slice, 8).should eq(4)
      u32(to_slice, 12).should eq(Pipewire::LibSPA::PodType::Int.value)
      u32(to_slice, 16).should eq(42)

      # string value
      size = u32(to_slice, 24)
      u32(to_slice, 28).should eq(Pipewire::LibSPA::PodType::String.value)
      size.should eq(6) # "hello\0"

      to_slice[32, 6].should eq(Bytes[104, 101, 108, 108, 111, 0]) # "hello\0"

      aligned8?(to_slice).should be_true
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
