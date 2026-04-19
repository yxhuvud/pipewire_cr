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

      def fraction(num : Int32, denom : Int32)
        write_header(8, LibSPA::PodType::Fraction)
        write_bytes(num)
        write_bytes(denom)
        align8
      end

      def rectangle(width : Int32, height : Int32)
        write_header(8, LibSPA::PodType::Rectangle)
        write_bytes(width)
        write_bytes(height)
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

      {% for entry in [
                        {Int32, 4, "Int"},
                        {Int64, 8, "Long"},
                        {Float32, 4, "Float"},
                        {Float64, 8, "Double"},
                        {Bool, 4, "Bool"},
                      ] %}

        {% type, size, pod = entry %}

        def array(values : Array({{type.id}}))
          write_array({{size}}, LibSPA::PodType::{{pod.id}}, values)
        end

        def range(default : {{type.id}}, min : {{type.id}}, max : {{type.id}})
          write_choice(LibSPA::Choice::Range, {{size}}, LibSPA::PodType::{{pod.id}}) do
            write_bytes(default)
            write_bytes(min)
            write_bytes(max)
          end
        end
      {% end %}

      private def write_array(element_size : Int32, element_type : LibSPA::PodType, values)
        reserve_header(LibSPA::PodType::Array) do
          write_header(element_size.to_u32, element_type)
          values.each { |v| write_bytes v }
        end
        align8
      end

      def object(obj_type : Pipewire::LibSPA::PodObjectType, obj_id : Pipewire::LibSPA::ParamType, &)
        reserve_header(LibSPA::PodType::Object) do
          write_bytes(obj_type.value)
          write_bytes(obj_id.value)
          yield self
        end
        align8
      end

      private def write_choice(choice_type : LibSPA::Choice, element_size : Int32, element_type : LibSPA::PodType, &)
        reserve_header(LibSPA::PodType::Choice) do
          write_bytes(choice_type.value)
          write_bytes(0) # flags
          write_header(element_size.to_u32, element_type)
          yield
        end
        align8
      end

      def prop(key : UInt32, flags : Pipewire::LibSPA::PropFlag = Pipewire::LibSPA::PropFlag::None, &)
        write_bytes(key)
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

      private def reserve_header(element_type : LibSPA::PodType, &)
        start = @io.pos
        write_header(0, element_type)
        body_start = @io.pos
        yield
        body_end = @io.pos
        size = (body_end - body_start).to_u32
        patch_size(start, size)
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
