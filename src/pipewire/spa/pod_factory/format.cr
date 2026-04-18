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
          @pod_factory.prop(LibSPA::Format::MediaType) { @pod_factory.id(id.value) }
        end

        def media_subtype(id : Pipewire::LibSPA::MediaSubType)
          @pod_factory.prop(LibSPA::Format::MediaSubtype) { @pod_factory.id(id.value) }
        end

        def audio_format(format : Pipewire::LibSPA::AudioFormat)
          @pod_factory.prop(LibSPA::Format::AUDIO_format) { @pod_factory.id(format.value) }
        end

        def audio_channels(channels : Int32)
          @pod_factory.prop(LibSPA::Format::AUDIO_channels) { @pod_factory.int(channels) }
        end

        def audio_rate(rate : Int32)
          @pod_factory.prop(LibSPA::Format::AUDIO_rate) { @pod_factory.int(rate) }
        end
      end
    end
  end
end
