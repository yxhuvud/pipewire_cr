require "../lib/lib_pipewire"
require "./event_listener"

module Pipewire
  class Metadata < Base(LibPipewire::Metadata)
    include EventListener

    EVENT_LISTENER_VERSION = LibPipewire::VERSION_METADATA_EVENTS

    event_listener property : UInt32, String, String, String -> LibC::Int

    def set_property(subject, key, type, value)
      LibPipewire.pw_metadata_set_property(self, subject, key, type, value)
    end

    def clear
      LibPipewire.pw_metadata_clear(self)
    end
  end
end
