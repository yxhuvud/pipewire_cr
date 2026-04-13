require "./spa/pod"
require "./device_info"
require "./event_listener"

module Pipewire
  class Device < Base(LibPipewire::Device)
    include EventListener

    EVENT_LISTENER_VERSION = LibPipewire::VERSION_DEVICE_EVENTS

    event_listener info : DeviceInfo -> Void
    event_listener param : Int32, LibSPA::ParamType, UInt32, UInt32, SPA::Pod -> Void

    def subscribe_params(ids : Array)
      LibPipewire.pw_device_subscribe_params(self, ids, ids.size)
    end

    def enum_params(seq, id, start, num, filter)
      LibPipewire.pw_device_enum_params(self, seq, id, start, num, filter)
    end

    def set_param(id, flags, pod)
      LibPipewire.pw_device_set_param(self, id, flags, pod)
    end

    def finalize
      LibPipewire.pw_proxy_destroy(self.to_unsafe.as(Pointer(LibPipewire::Proxy)))
    end
  end
end
