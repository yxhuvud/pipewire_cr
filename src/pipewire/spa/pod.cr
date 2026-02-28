require "./type_info"

module Pipewire
  module SPA
    class Pod < Base(LibSPA::Pod)
      value_getter size : UInt32
      value_getter type : LibSPA::PodType

      private def self.spa_ptrinside(p0 : T*, s0, p1 : U*, s1) forall T, U
        if p0.address <= p1.address && s1 <= s0 && p1.address - p0.address <= s0 - s1
          {true, (p0.address + s0) - (p1.address + s1)}
        else
          {false, 0}
        end
      end

      private def self.spa_ptr_inside_and_aligned(p0 : T*, s0, p1 : U*, s1) forall T, U
        if p1.address & alignof(U) - 1 == 0
          self.spa_ptrinside(p0, s0, p1, s1)
        else
          {false, 0}
        end
      end

      private def self.spa_ptr_type_inside(p0 : T*, s0, p1 : U*) forall T, U
        self.spa_ptr_inside_and_aligned(p0, s0, p1, sizeof(U))
      end

      private def self.spa_pod_prop_is_inside(body : LibSPA::PodObjectBody*, size, iter : LibSPA::PodProp*)
        (result = self.spa_ptr_type_inside(body, size, iter))[0] && result[1] >= iter.value.value.size
      end

      private def self.spa_pod_is_inside(pod : LibSPA::Pod*, size, iter : LibSPA::Pod*)
        (result = self.spa_ptr_type_inside(pod, size, iter))[0] && result[1] >= iter.value.size
      end

      alias Value = Nil | Bool | Int32 | Int64 | Float32 | Float64 | String | Array(Value) | Hash(String, Value)

      def self.to_value(type : LibSPA::PodType, size : UInt32, body : Void*, type_info_list : TypeInfoList) : Value
        case type
        when LibSPA::PodType::None
          nil
        when LibSPA::PodType::Bool
          if size >= sizeof(Int32)
            body.as(Int32*).value == 0
          else
            nil
          end
        when LibSPA::PodType::Id
          id = body.as(UInt32*).value
          type_info = TypeInfoList.root.find_type(id)

          if !type_info.nil?
            type_info.short_name
          else
            "id-#{id.to_s(16).rjust(8, '0')}"
          end
        when LibSPA::PodType::Int
          if size >= sizeof(Int32)
            body.as(Int32*).value
          else
            nil
          end
        when LibSPA::PodType::Long, LibSPA::PodType::Fd
          if size >= sizeof(Int64)
            body.as(Int64*).value
          else
            nil
          end
        when LibSPA::PodType::Float
          if size >= sizeof(Float32)
            body.as(Float32*).value
          else
            nil
          end
        when LibSPA::PodType::Double
          if size >= sizeof(Float64)
            body.as(Float64*).value
          else
            nil
          end
        when LibSPA::PodType::String
          char_pointer = body.as(LibC::Char*)
          if size > 0 && char_pointer[size - 1] == 0
            String.new(char_pointer)
          else
            nil
          end
        when LibSPA::PodType::Bytes
          # TODO: Implement this.
          nil
        when LibSPA::PodType::Rectangle
          # TODO: Implement this.
          nil
        when LibSPA::PodType::Fraction
          # TODO: Implement this.
          nil
        when LibSPA::PodType::Bitmap
          # TODO: Implement this.
          nil
        when LibSPA::PodType::Array
          if size >= sizeof(LibSPA::PodArrayBody)
            array_body = body.as(LibSPA::PodArrayBody*)
            element_pointer = (array_body + 1).as(Void*)
            info_list = type_info_list[0].values.any? ? type_info_list[0].values : type_info_list

            array = [] of Value

            while array_body.value.child.size > 0 && self.spa_ptrinside(body, size, element_pointer, array_body.value.child.size)[0]
              array << self.to_value(array_body.value.child.type, array_body.value.child.size, element_pointer, info_list)
              element_pointer = element_pointer + array_body.value.child.size
            end

            array
          else
            nil
          end
        when LibSPA::PodType::Struct
          pod_body = body.as(LibSPA::Pod*)
          pod_pointer = pod_body

          array = [] of Value

          while self.spa_pod_is_inside(pod_body, size, pod_pointer)
            array << self.to_value(pod_pointer.value.type, pod_pointer.value.size, (pod_pointer + 1).as(Void*), type_info_list)
            pod_pointer = (pod_pointer.as(Void*) + ((sizeof(LibSPA::Pod) + pod_pointer.value.size - 1) | (LibSPA::POD_ALIGN - 1)) + 1).as(LibSPA::Pod*)
          end

          array
        when LibSPA::PodType::Object
          object_body = body.as(LibSPA::PodObjectBody*)
          prop_pointer = (object_body + 1).as(LibSPA::PodProp*)

          ti = type_info_list.find_type(object_body.value.type.to_i.to_u)
          info_list = ti ? ti.values : type_info_list

          hash = {} of String => Value

          while self.spa_pod_prop_is_inside(object_body, size, prop_pointer)
            ii = info_list.find_type(prop_pointer.value.key.value.to_u)
            name = ii ? ii.short_name : "id-#{prop_pointer.value.key.value.to_s(16).rjust(8, '0')}"

            hash[name] = self.to_value(prop_pointer.value.value.type, prop_pointer.value.value.size, (prop_pointer + 1).as(Void*), ii ? ii.values : TypeInfoList.root)
            prop_pointer = (prop_pointer.as(Void*) + ((((sizeof(LibSPA::PodProp) + prop_pointer.value.value.size) - 1) | (LibSPA::POD_ALIGN - 1)) + 1)).as(LibSPA::PodProp*)
          end

          hash
        when LibSPA::PodType::Sequence
          nil
        when LibSPA::PodType::Pointer
          # TODO: Implement this.
          nil
        when LibSPA::PodType::Choice
          # TODO: Implement this.
          nil
        when LibSPA::PodType::Pod
          # TODO: Implement this.
          nil
        end
      end

      def to_value
        self.class.to_value(self.type, self.size, (self.to_unsafe + 1).as(Void*), TypeInfoList.root)
      end
    end
  end
end
