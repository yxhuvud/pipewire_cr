require "./spa/dict"
require "./client"
require "./device"
require "./node"
require "./metadata"

module Pipewire
  class Registry < Base(LibPipewire::Registry)
    include EventListener

    EVENT_LISTENER_VERSION = LibPipewire::VERSION_REGISTRY_EVENTS

    event_listener global : UInt32, LibPipewire::Perm, String, UInt32, SPA::Dict -> Void
    event_listener global_remove : UInt32 -> Void

    {% begin %}
      {% for name in %w[
                       Client
                       Device
                       Metadata
                       Node
                     ] %}
        def bind_{{ name.downcase.id }}(id, item_type, autoremove = true) : {{ name.id }}
          bound_object = {{ name.id }}.new(LibPipewire.pw_registry_bind(self, id, item_type, LibPipewire::VERSION_{{ name.upcase.id }}, 0).as(LibPipewire::{{ name.id }}*))

          if autoremove
            self.on_global_remove do |removed_id|
              if removed_id == id
                {% if parse_type(name).resolve.has_method?(:remove_event_listeners) %}
                  bound_object.remove_event_listeners
                {% end %}
              end
            end
          end

          bound_object
        end
      {% end %}
    {% end %}

    def finalize
      LibPipewire.pw_proxy_destroy(self.to_unsafe.as(Pointer(LibPipewire::Proxy)))
    end
  end
end
