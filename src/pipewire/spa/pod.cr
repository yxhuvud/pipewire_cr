require "./type_info"
require "./pod_factory"
require "./pod_factory/format"

module Pipewire
  module SPA
    struct Pod
      def initialize(bytes : Bytes)
        @bytes = bytes
      end

      def to_unsafe
        bytes.to_unsafe.as(LibSPA::Pod*)
      end

      private getter :bytes

      def self.new(&)
        pod = PodFactory.new
        yield pod

        new(pod)
      end

      def self.format(&)
        new(PodFactory::Format.new { |f| yield f })
      end

      def self.new(factory : PodFactory)
        new(factory.to_slice)
      end

      # Events received from pipewire are not owned by us, but live
      # only through the processing of the event. So a copy is made of
      # the supplied buffer. Supply the read_only flag to avoid the
      # copy, but be careful to not use the resulting pod after the
      # event processing is done.
      def self.new(pointer : LibSPA::Pod*, read_only : Bool = true)
        raise Pipewire::NullPointerError.new unless pointer

        size = pointer.as(UInt32*).value
        bytes = Bytes.new(pointer.as(UInt8*), size: size + 8, read_only: read_only)
        bytes = bytes.dup
        new(bytes)
      end

      def size : UInt32
        decode(UInt32, bytes)
      end

      def type : LibSPA::PodType
        LibSPA::PodType.new(decode(UInt32, bytes + 4))
      end

      alias Value = Nil | Bool | Int32 | Int64 | Float32 | Float64 | String |
                    Array(Value) | Hash(String, Value) | Tuple(Int32, Int32)

      private def enforce_type_and_size!(expected_type : LibSPA::PodType, expected_size)
        raise "Is of type #{type}, expected #{expected_type}" if expected_type != type
        raise "Size #{size} is invalid for type #{type}" if size != expected_size
      end

      # General comment about the headerfree flag: It is for the cases where
      # the caller stores the headerfree values in a list, like for example
      # arrays. In those cases the type and size are stored in the
      # header of the array, and only there - not in the individual
      # members. That is also why arrays and similar enforces same
      # size of each element. Hence headerfree flag is irrelevant for types
      # that are not uniform in size.

      def as_bool(headerfree = false) : Bool
        enforce_type_and_size!(:bool, 4) unless headerfree
        decode(Int32, body(headerfree)) != 0
      end

      def as_id(type_info_list = TypeInfoList.root, headerfree = false) : String
        enforce_type_and_size!(:id, 4) unless headerfree
        resolve_id(decode(UInt32, body(headerfree)), type_info_list)
      end

      def as_int(headerfree = false) : Int32
        enforce_type_and_size!(:int, 4) unless headerfree
        decode(Int32, body(headerfree))
      end

      def as_long(headerfree = false) : Int64
        enforce_type_and_size!(:long, 8) unless headerfree
        decode(Int64, body(headerfree))
      end

      def as_fd(headerfree = false) : Int64
        enforce_type_and_size!(:fd, 8) unless headerfree
        decode(Int64, body(headerfree))
      end

      def as_float(headerfree = false) : Float32
        enforce_type_and_size!(:float, 4) unless headerfree
        decode(Float32, body(headerfree))
      end

      def as_double(headerfree = false) : Float64
        enforce_type_and_size!(:double, 8) unless headerfree
        decode(Float64, body(headerfree))
      end

      def as_string : String
        body = body(false)
        if size > 0 && body[size - 1] == 0
          String.new(body[0, size - 1])
        else
          raise "Invalid string in pod"
        end
      end

      def as_rectangle(headerfree = false)
        enforce_type_and_size!(:rectangle, 8) unless headerfree
        body(headerfree).to_unsafe.as(Tuple(Int32, Int32)*).value
      end

      def as_fraction(headerfree = false)
        enforce_type_and_size!(:fraction, 8) unless headerfree
        body(headerfree).to_unsafe.as(Tuple(Int32, Int32)*).value
      end

      def as_array(type_info_list = TypeInfoList.root)
        enforce_type_and_size!(:array, size)
        body = body(false)

        element_size, array_type = read_header(body)
        element_count = (size - 8) // element_size
        body += 8

        Array(Value).new(size: element_count) do |i|
          self.class.new(body[i * element_size, element_size])
            .to_value(array_type, type_info_list, headerfree: true)
        end
      end

      def as_struct(type_info_list = TypeInfoList.root)
        enforce_type_and_size!(:struct, size)
        body = body(false)

        arr = Array(Value).new
        while body.size > 0
          pod = self.class.new(body)
          body += pod.padded_size
          arr << pod.to_value(pod.type, type_info_list)
        end
        arr
      end

      def as_object(type_info_list = TypeInfoList.root)
        enforce_type_and_size!(:object, size)
        body = body(false)

        object_type = Pipewire::LibSPA::PodObjectType.new(decode(UInt32, body))
        # object_id = Pipewire::LibSPA::ParamType.new(decode(UInt32, body + 4))
        body += 8
        info_list = resolve_info_list(type_info_list, object_type)

        hash = {} of String => Value
        while body.size > 0
          key_id = decode(UInt32, body)
          key = resolve_id(key_id, info_list)
          ii = info_list.find_type(key_id)
          # flags = decode(UInt32, body + 4)
          body += 8
          pod = self.class.new(body)
          body += pod.padded_size
          hash[key] = pod.to_value(pod.type, ii && ii.values.any? ? ii.values : info_list)
        end
        hash
      end

      def as_choice(type_info_list = TypeInfoList.root) : Value
        enforce_type_and_size!(:choice, size)
        body = body(false)

        choice_type = Pipewire::LibSPA::Choice.new(decode(UInt32, body))
        _flags = decode(UInt32, body + 4)
        element_size, element_type = read_header(body + 8)
        body += 16
        # Predefining hash to make inference work, as the branches confused the compiler.
        hsh = {} of String => Value
        case choice_type
        in LibSPA::Choice::Range
          raise "Invalid size for choice range" if size != 16 + element_size * 3

          hsh["default"] = self.class.new(body).to_value(element_type, type_info_list, headerfree: true)
          hsh["min"] = self.class.new(body + element_size).to_value(element_type, type_info_list, headerfree: true)
          hsh["max"] = self.class.new(body + element_size * 2).to_value(element_type, type_info_list, headerfree: true)
        in LibSPA::Choice::Step
          raise "Invalid size for choice step" if size != 16 + element_size * 3

          hsh["default"] = self.class.new(body).to_value(element_type, type_info_list, headerfree: true)
          hsh["min"] = self.class.new(body + element_size).to_value(element_type, type_info_list, headerfree: true)
          hsh["max"] = self.class.new(body + element_size * 2).to_value(element_type, type_info_list, headerfree: true)
          hsh["step"] = self.class.new(body + element_size * 3).to_value(element_type, type_info_list, headerfree: true)
        in LibSPA::Choice::Enum
          raise "Invalid size for choice enum" if (size - 16) % element_size != 0

          hsh["default"] = self.class.new(body).to_value(element_type, type_info_list, headerfree: true)
          hsh["enums"] = Array(Value).new(size: (size - 16) // element_size - 1) do |i|
            self.class.new(body + (i + 1) * element_size).to_value(element_type, type_info_list, headerfree: true)
          end
        in LibSPA::Choice::Flags
          return "<TODO: Choice Flags>"
        in LibSPA::Choice::None
          raise "Invalid size for choice none" if size != 16
          hsh["default"] = self.class.new(body).to_value(element_type, type_info_list, headerfree: true)
        end
        hsh
      end

      def to_value(type : LibSPA::PodType = self.type, type_info_list = TypeInfoList.root, headerfree = false) : Value
        case type
        in .none?      then nil
        in .bool?      then as_bool(headerfree)
        in .id?        then as_id(type_info_list, headerfree)
        in .int?       then as_int(headerfree)
        in .long?      then as_long(headerfree)
        in .fd?        then as_fd(headerfree)
        in .float?     then as_float(headerfree)
        in .double?    then as_double(headerfree)
        in .string?    then as_string
        in .bytes?     then "<TODO: bytes>"
        in .rectangle? then as_rectangle(headerfree)
        in .fraction?  then as_fraction(headerfree)
        in .bitmap?    then "<TODO: bitmap>"
        in .array?     then as_array(type_info_list)
        in .start?     then raise NotImplementedError.new("Not relevant for Pod values")
        in .struct?    then as_struct(type_info_list)
        in .object?    then as_object(type_info_list)
        in .sequence?  then "<TODO: sequence>"
        in .pointer?   then "<TODO: pointer>"
        in .choice?    then as_choice(type_info_list)
        in .pod?       then "<TODO: pod>"
        end
      end

      private def body(headerfree)
        headers = headerfree ? 0 : 8
        body = bytes + headers
        # Ensure nested pods are right-sized, to avoid having
        # unbounded size in structs/objects. It is easier to fix here
        # than at the various sources as we have the size here.
        # Headerfree pods are fixed size and pre-chopped.
        if (body.size > size) && !headerfree
          body[0, size]
        else
          body
        end
      end

      private def read_header(body)
        size = decode(UInt32, body)
        type = LibSPA::PodType.new(decode(UInt32, body + 4))
        {size, type}
      end

      private def resolve_id(id, type_info_list)
        type_info = type_info_list.find_type(id)
        type_info ? type_info.short_name : "id-0x#{id.to_s(16).rjust(8, '0')}"
      end

      private def resolve_info_list(type_info_list, object_type)
        info_list = type_info_list.any? && type_info_list[0].values.any? ? type_info_list[0].values : type_info_list
        ti = info_list.find_type(object_type.value)
        ti && ti.values.any? ? ti.values : type_info_list
      end

      def padded_size
        full_size = 8 + size

        (full_size + 7) & ~7
      end

      macro decode(type, slice)
        IO::ByteFormat::LittleEndian.decode({{ type }}, {{ slice }})
      end
    end
  end
end
