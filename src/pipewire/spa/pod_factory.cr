require "../../lib/lib_spa"

module Pipewire
  module SPA
    class PodFactory
      getter io : IO::Memory

      def initialize
        @io = IO::Memory.new
      end

      def int(value : Int32)
        write_header(4, LibSPA::PodType::Int)
        write_bytes(value)
        align8
      end

      def long(value : Int64)
        write_header(8, LibSPA::PodType::Long)
        write_bytes(value)
        align8
      end

      def id(value)
        write_header(4, LibSPA::PodType::Id)
        write_bytes value.to_u32
        align8
      end

      def bool(value : Bool)
        write_header(4, LibSPA::PodType::Bool)
        write_bytes value ? 1 : 0
        align8
      end

      def float(value : Float32)
        write_header(4, LibSPA::PodType::Float)
        write_bytes value
        align8
      end

      def double(value : Float64)
        write_header(8, LibSPA::PodType::Double)
        write_bytes value
        align8
      end

      def string(value : String)
        bytes = value.to_slice
        size = bytes.size + 1

        write_header(size.to_u32, LibSPA::PodType::String)
        @io.write(bytes)
        @io.write_byte(0)
        align8
      end

      {% begin %}
        {% for args in [
                         {"Bool", 4, "Bool"},
                         {"Int32", 4, "Int"},
                         {"Int64", 8, "Long"},
                         {"Float32", 4, "Float"},
                         {"Float64", 8, "Double"},
                       ] %}
          {% arg_type, value_size, pod_type = args %}
          def array(values : Array({{arg_type.id}}))
            start = @io.pos

            write_header(0, LibSPA::PodType::Array)

            body_start = @io.pos

            write_header({{value_size}}, LibSPA::PodType::{{pod_type.id}})

            values.each do |v|
              write_bytes v
            end

            body_end = @io.pos
            size = (body_end - body_start).to_u32

            patch_size(start, size)

            align8
          end
        {% end %}
      {% end %}

      def object(obj_type : Pipewire::LibSPA::PodObjectType, obj_id : Pipewire::LibSPA::ParamType, &)
        start = @io.pos

        # reserve header
        write_header(0, LibSPA::PodType::Object)

        body_start = @io.pos

        write_bytes(obj_type.value)
        write_bytes(obj_id.value)

        yield self

        body_end = @io.pos
        size = (body_end - body_start).to_u32

        # patch header
        patch_size(start, size)

        align8
      end

      def prop(key : UInt32, flags : Pipewire::LibSPA::PropFlag = Pipewire::LibSPA::PropFlag::None, &)
        write_bytes(key)
        write_bytes(flags.value)
        yield self
      end

      # FIXME: Separate builder for audio and video format objects.
      # This is just to keep the boilerplate in example down. It is
      # still horrible though.
      def prop(key : Pipewire::LibSPA::Format, flags : Pipewire::LibSPA::PropFlag = Pipewire::LibSPA::PropFlag::None, &)
        write_bytes(key.value.to_u32)
        write_bytes(flags.value)
        yield self
      end

      private def align8
        pad = (8 - (@io.pos % 8)) % 8
        pad.times { @io.write_byte(0) }
      end

      private def write_header(size : UInt32, type : LibSPA::PodType)
        write_bytes(size)
        write_bytes(type.value)
      end

      private def write_bytes(value)
        @io.write_bytes(value, IO::ByteFormat::LittleEndian)
      end

      private def patch_size(offset : Int32, size : UInt32)
        current = @io.pos
        @io.pos = offset
        write_bytes(size)
        @io.pos = current
      end

      def to_unsafe
        to_slice.to_unsafe.as(LibSPA::Pod*)
      end

      def to_slice
        @io.to_slice
      end
    end
  end
end
