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

        def audio_format(format : Pipewire::LibSPA::AudioFormat)
          prop(LibSPA::Format::AUDIO_format) { add_id(format) }
        end

        def audio_channels(channels : Int32)
          prop(LibSPA::Format::AUDIO_channels) { int(channels) }
        end

        def audio_rate(rate : Int32)
          prop(LibSPA::Format::AUDIO_rate) { int(rate) }
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
      end
    end
  end
end
