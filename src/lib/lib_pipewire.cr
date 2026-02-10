require "./lib_spa"

module Pipewire
  @[Link("pipewire-0.3", ldflags: "#{__DIR__}/../../build/shim_pipewire.o")]
  lib LibPipewire
    @[Flags]
    enum StreamFlag
      Autoconnect
      Inactive
      MapBuffers
      Driver
      RtProcess
      NoConvert
      Exclusive
      DontReconnect
      AllocBuffers
      Trigger
      Async
      EarlyProcess
      RtTriggerDone
    end

    enum StreamState
      Error
      Unconnected
      Connecting
      Paused
      Streaming
    end

    type Loop = Void
    type MainLoop = Void
    type Stream = Void
    type Context = Void
    type Properties = Void
    type Core = Void

    alias Direction = LibSPA::Direction

    struct StreamEvent
      version : UInt32 # 2
      # Irrelevant entries:
      destroy : Void* -> Void
      state_changed : Void* -> Void # Not the true signature
      control_info : Void* -> Void  #         --
      io_changed : Void* -> Void
      param_changed : Void* -> Void
      add_buffer : Void* -> Void
      remove_buffer : Void* -> Void
      process : Void* -> Void # The relevant one
      drained : Void* -> Void
      command : Void* -> Void
      trigger_done : Void* -> Void
    end

    fun pw_init(LibC::Int*, LibC::Char**) : Void

    fun pw_main_loop_new(Properties*) : MainLoop*
    fun pw_main_loop_get_loop(loop : MainLoop*) : Loop*
    fun pw_context_new(loop : Loop*, properties : Properties*, userdata : UInt64) : Context*
    fun pw_context_connect(context : Context*, properties : Properties*, userdata_size : UInt64) : Core*

    fun pw_stream_new_simple(loop : Loop*,
                             name : LibC::Char*,
                             properties : Properties*,
                             stream_events : StreamEvent*,
                             user_data : Void*) : Stream*

    fun pw_properties_new_string(object : LibC::Char*) : Properties*
    fun pw_stream_connect(
      stream : Stream*,
      direction : Direction,
      target_id : UInt32,
      flags : StreamFlag,
      params : LibSPA::Pod**,
      n_params : UInt32,
    ) : LibC::Int

    fun pw_loop_enter = pw_loop_enter_shim(loop : Loop*) : Void
    fun pw_loop_leave = pw_loop_leave_shim(loop : Loop*) : Void
    fun pw_loop_iterate = pw_loop_iterate_shim(loop : Loop*, timeout : LibC::Int) : LibC::Int
    fun pw_loop_get_fd = pw_loop_get_fd_shim(loop : Loop*) : LibC::Int
  end
end
