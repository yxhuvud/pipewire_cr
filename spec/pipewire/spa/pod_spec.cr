require "../../spec_helper"

describe Pipewire::SPA::Pod do
  describe ".new" do
    it "raises when receiving a null pointer" do
      expect_raises(::Pipewire::NullPointerError) { Pipewire::SPA::Pod.new(Pointer(Pipewire::LibSPA::Pod).null) }
    end
  end

  describe "#to_value" do
    it "returns nil given a pod of type None" do
      pod = Pipewire::SPA::Pod.new do |f|
        f.none
      end

      pod.to_value.should be_nil
    end

    it "returns a boolean given a pod of type Bool" do
      pod = Pipewire::SPA::Pod.new do |f|
        f.bool(true)
      end

      pod.to_value.should eq true
    end

    it "returns a derived value given a pod of type Id" do
      pod = Pipewire::SPA::Pod.new do |f|
        f.id(3)
      end

      # So where does this "Id" string come from? Without any context
      # for the type info list it will end up picking from Podtype. No
      # idea why, I suppose the proper test will be for prop, which
      # will induce the type info into the question.
      pod.to_value.should eq "Id"
    end

    it "returns an integer given a pod of type Int32" do
      pod = Pipewire::SPA::Pod.new do |f|
        f.int(42)
      end

      pod.to_value.should eq 42
    end

    it "returns a Int64 given a pod of type Int64" do
      pod = Pipewire::SPA::Pod.new do |f|
        f.long(42)
      end

      pod.to_value.should eq 42_i64
    end

    # it "returns a integer representing the file handle for fd" do
    #   pod = Pipewire::SPA::Pod.new do |f|
    #     f.fd(42)
    #   end

    #   pod.to_value.should eq 42
    # end

    it "returns a float given a pod of type Float" do
      pod = Pipewire::SPA::Pod.new do |f|
        f.float(3.14)
      end

      pod.to_value.should eq 3.14_f32
    end

    it "returns a double given a pod of type Double" do
      pod = Pipewire::SPA::Pod.new do |f|
        f.double(3.14)
      end

      pod.to_value.should eq 3.14_f64
    end

    it "returns a string given a pod of type String" do
      pod = Pipewire::SPA::Pod.new do |f|
        f.string("hello")
      end

      pod.to_value.should eq "hello"
    end

    it "returns a rectangle given a pod of type Rectangle" do
      pod = Pipewire::SPA::Pod.new do |f|
        f.rectangle(800, 600)
      end

      pod.to_value.should eq({800, 600})
    end

    it "returns a fraction given a pod of type Fraction" do
      pod = Pipewire::SPA::Pod.new do |f|
        f.fraction(1, 2)
      end

      pod.to_value.should eq({1, 2})
    end

    it "returns an array of values given a pod of type Array" do
      pod = Pipewire::SPA::Pod.new do |f|
        f.array [1, 2, 3]
      end

      pod.to_value.should eq [1, 2, 3]
    end

    it "returns a list of values given a pod of type Struct" do
      pod = Pipewire::SPA::Pod.new do |f|
        f.struct do |s|
          s.int(42)
          s.string("hello")
        end
      end

      pod.to_value.should eq [42, "hello"]
    end

    it "returns a hash of values given a pod of type Object" do
      pod = Pipewire::SPA::Pod.new do |f|
        f.object(Pipewire::LibSPA::PodObjectType::Format,
          Pipewire::LibSPA::ParamType::Invalid) do |o|
          o.prop(1) { |p| p.int(42) }
          o.prop(2) { |p| p.string("hello") }
        end
      end

      pod.to_value.should eq({"mediaType" => 42, "mediaSubtype" => "hello"})
    end

    it "returns an array for choice enum pods" do
      pod = Pipewire::SPA::Pod.new do |f|
        f.choice_enum_id(Pipewire::LibSPA::AudioFormat::F32, {
          Pipewire::LibSPA::AudioFormat::F32,
          Pipewire::LibSPA::AudioFormat::S16,
        })
      end

      # FIXME: Figure out how to get the correct typeinfolist here.
      pod.to_value.should eq(
        {"default" => "id-0x0000011b", "enums" => ["id-0x0000011b", "id-0x00000103"]}
      )
    end

    it "returns a hash for choice range pods" do
      pod = Pipewire::SPA::Pod.new do |f|
        f.range(42, 0, 100)
      end

      pod.to_value.should eq({"default" => 42, "min" => 0, "max" => 100})
    end

    # TODO: Add specs when factory supports choice step and choice flags
    # it "returns a hash for choice step pods" do
    # it "returns a hash for choice flags pods" do
  end
end
