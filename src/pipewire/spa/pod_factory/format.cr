require "../pod_factory"

module Pipewire
  module SPA
    class PodFactory
      class Format
        def self.new(&)
          factory = PodFactory.new
          format_builder = new(factory)
          factory.object(LibSPA::PodObjectType::Format, LibSPA::ParamType::EnumFormat) do
            yield format_builder, factory
          end
          factory
        end

        def initialize(pod_factory : PodFactory)
          @pod_factory = pod_factory
        end

        def media(main_id : Pipewire::LibSPA::MediaType,
                  subtype_id : Pipewire::LibSPA::MediaSubType)
          media_type(main_id)
          media_subtype(subtype_id)
        end

        def media_type(id : Pipewire::LibSPA::MediaType)
          prop(LibSPA::Format::MediaType) { add_id(id) }
        end

        def media_subtype(id : Pipewire::LibSPA::MediaSubType)
          prop(LibSPA::Format::MediaSubtype) { add_id(id) }
        end

        def audio_format(*formats : Pipewire::LibSPA::AudioFormat)
          if formats.size == 1
            prop(LibSPA::Format::AUDIO_format) { add_id(formats.first) }
          else
            prop(LibSPA::Format::AUDIO_format) do
              self.enum(formats[0], formats)
            end
          end
        end

        def video_format(*formats : Pipewire::LibSPA::VideoFormat)
          if formats.size == 1
            prop(LibSPA::Format::VIDEO_format) { add_id(formats.first) }
          else
            prop(LibSPA::Format::VIDEO_format) do
              self.enum(formats[0], formats)
            end
          end
        end

        def video_size(size : Tuple(Int32, Int32))
          prop(LibSPA::Format::VIDEO_size) { @pod_factory.rectangle(*size) }
        end

        def video_size(default : Tuple(Int32, Int32), min : Tuple(Int32, Int32), max : Tuple(Int32, Int32))
          prop(LibSPA::Format::VIDEO_size) do
            self.range(default, min, max, LibSPA::PodType::Rectangle)
          end
        end

        def video_framerate(rate : Tuple(Int32, Int32))
          prop(LibSPA::Format::VIDEO_framerate) { @pod_factory.fraction(*rate) }
        end

        def video_framerate(default : Tuple(Int32, Int32), min : Tuple(Int32, Int32), max : Tuple(Int32, Int32))
          prop(LibSPA::Format::VIDEO_framerate) do
            self.range(default, min, max, LibSPA::PodType::Fraction)
          end
        end

        def audio_channels(channels : Int32)
          prop(LibSPA::Format::AUDIO_channels) { int(channels) }
        end

        def audio_rate(rate : Int32)
          prop(LibSPA::Format::AUDIO_rate) { int(rate) }
        end

        def audio_rate(default : Int32, min : Int32, max : Int32)
          prop(LibSPA::Format::AUDIO_rate) do
            self.range(default, min, max, LibSPA::PodType::Int)
          end
        end

        private def prop(key : LibSPA::Format, &)
          @pod_factory.prop(key.to_u32) { yield }
        end

        private def add_id(key)
          @pod_factory.id(key.value)
        end

        private def int(value)
          @pod_factory.int(value)
        end

        private def enum(default, values : Enumerable(T)) forall T
          @pod_factory.choice_enum_id(default, values)
        end

        private def range(default, min, max, type)
          @pod_factory.range(default, min, max, type)
        end
      end
    end
  end
end
