require "./lib_spa"

module Pipewire
  @[Link("pipewire-0.3", ldflags: "#{__DIR__}/../../build/shim_pipewire.o")]
  lib LibPipewire
    VERSION_CORE_EVENTS     = 1
    VERSION_REGISTRY_EVENTS = 0
    VERSION_NODE_EVENTS     = 0
    VERSION_STREAM_EVENTS   = 2
    VERSION_REGISTRY        = 3
    VERSION_NODE            = 3

    NODE_EVENT_PARAM = 1

    ID_ANY  = 0xffffffffu32
    ID_CORE =             0

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

    enum NodeState
      PW_NODE_STATE_ERROR     = -1
      PW_NODE_STATE_CREATING  =  0
      PW_NODE_STATE_SUSPENDED =  1
      PW_NODE_STATE_IDLE      =  2
      PW_NODE_STATE_RUNNING   =  3
    end

    type Loop = Void
    type MainLoop = Void
    type Stream = Void
    type Context = Void
    type Core = Void
    type Registry = Void
    type Proxy = Void
    type Node = Void

    alias Direction = LibSPA::Direction

    struct Properties
      dict : LibSPA::Dict
      flags : UInt32
    end

    struct NodeInfo
      id : UInt32
      max_input_ports : UInt32
      max_output_ports : UInt32
      change_mask : UInt64
      n_input_ports : UInt32
      n_output_ports : UInt32
      state : NodeState
      error : LibC::Char*
      properties : LibSPA::Dict*
      params : LibSPA::ParamInfo*
      n_params : UInt32
    end

    struct NodeEvents
      version : UInt32
      info : Void*, NodeInfo* -> Void
      param : Void*, Int32, UInt32, UInt32, UInt32, LibSPA::Pod* -> Void
    end

    struct StreamControl
      flags : UInt32
      default : Float32
      min : Float32
      max : Float32
      values : Float32*
      n_values : UInt32
      max_values : UInt32
    end

    struct Buffer
      buffer : LibSPA::Buffer*
      user_data : Void*
      size : UInt64
      requested : UInt64
      time : UInt64
    end

    struct StreamEvents
      version : UInt32
      destroy : Void* -> Void
      state_changed : Void*, StreamState, StreamState, LibC::Char* -> Void
      control_info : Void*, UInt32, StreamControl* -> Void
      io_changed : Void*, UInt32, Void*, UInt32 -> Void
      param_changed : Void*, UInt32, LibSPA::Pod* -> Void
      add_buffer : Void*, Buffer* -> Void
      remove_buffer : Void*, Buffer* -> Void
      process : Void* -> Void
      drained : Void* -> Void
      command : Void*, LibSPA::Command* -> Void
      trigger_done : Void* -> Void
    end

    struct RegistryEvents
      version : UInt32
      global : Void*, UInt32, UInt32, LibC::Char*, UInt32, LibSPA::Dict* -> Void
      global_remove : Void*, UInt32 -> Void
    end

    struct CoreInfo
      id : UInt32
      cookie : UInt32
      user_name : LibC::Char*
      host_name : LibC::Char*
      version : LibC::Char*
      change_mask : UInt64
    end

    struct CoreEvents
      version : UInt32
      info : Void*, CoreInfo* -> Void
      done : Void*, UInt32, LibC::Int -> Void
      ping : Void*, UInt32, LibC::Int -> Void
      error : Void*, UInt32, LibC::Int, LibC::Int, LibC::Char* -> Void
      remove_id : Void*, UInt32 -> Void
      bound_id : Void*, UInt32, UInt32 -> Void
      add_mem : Void*, UInt32, UInt32, LibC::Int, UInt32 -> Void
      remove_mem : Void*, UInt32 -> Void
      bound_props : Void*, UInt32, UInt32, LibSPA::Dict* -> Void
    end

    fun pw_init(argc : LibC::Int*, argv : LibC::Char**) : Void

    fun pw_get_headers_version = pw_get_headers_version_shim : LibC::Char*
    fun pw_get_library_version : LibC::Char*

    fun pw_main_loop_new(properties : LibSPA::Dict*) : MainLoop*
    fun pw_main_loop_get_loop(loop : MainLoop*) : Loop*
    @[Raises]
    fun pw_main_loop_run(loop : MainLoop*) : LibC::Int
    fun pw_main_loop_quit(loop : MainLoop*) : LibC::Int
    fun pw_main_loop_destroy(loop : MainLoop*) : Void
    fun pw_context_new(loop : Loop*, properties : Properties*, user_data_size : LibC::SizeT) : Context*
    fun pw_context_connect(context : Context*, properties : Properties*, user_data_size : LibC::SizeT) : Core*
    fun pw_context_destroy(context : Context*) : Void
    fun pw_core_add_listener(core : Core*, listener : LibSPA::Hook*, events : CoreEvents*, data : Void*) : LibC::Int
    fun pw_core_get_registry(core : Core*, version : UInt32, user_data_size : LibC::SizeT) : Registry*
    fun pw_core_sync(core : Core*, id : UInt32, seq : LibC::Int) : LibC::Int
    fun pw_core_disconnect(core : Core*) : LibC::Int
    fun pw_registry_add_listener(registry : Registry*, listener : LibSPA::Hook*, events : RegistryEvents*, data : Void*) : LibC::Int
    fun pw_registry_bind(registry : Registry*, id : UInt32, type : LibC::Char*, version : UInt32, user_data_size : LibC::SizeT) : Void*
    fun pw_node_add_listener(object : Node*, listener : LibSPA::Hook*, events : NodeEvents*, data : Void*) : LibC::Int
    fun pw_node_set_param(object : Node*, id : UInt32, flags : UInt32, param : LibSPA::Pod*) : LibC::Int
    fun pw_stream_new(core : Core*, name : LibC::Char*, properties : Properties*) : Stream*
    fun pw_stream_new_simple(loop : Loop*, name : LibC::Char*, properties : Properties*, stream_events : StreamEvents*, user_data : Void*) : Stream*
    fun pw_stream_add_listener(stream : Stream*, listener : LibSPA::Hook*, events : StreamEvents*, data : Void*) : LibC::Int
    fun pw_stream_dequeue_buffer(stream : Stream*) : Buffer*
    fun pw_stream_queue_buffer(stream : Stream*, buffer : Buffer*) : LibC::Int
    fun pw_properties_new(key : LibC::Char*, ...) : Properties*
    fun pw_properties_new_string(object : LibC::Char*) : Properties*
    fun pw_properties_new_dict(dict : LibSPA::Dict*) : Properties*
    fun pw_stream_connect(stream : Stream*, direction : Direction, target_id : UInt32, flags : StreamFlag, params : LibSPA::Pod**, n_params : UInt32) : LibC::Int
    fun pw_stream_destroy(stream : Stream*) : Void
    fun pw_proxy_destroy(proxy : Proxy*) : Void

    fun pw_loop_enter = pw_loop_enter_shim(loop : Loop*) : Void
    fun pw_loop_leave = pw_loop_leave_shim(loop : Loop*) : Void
    fun pw_loop_iterate = pw_loop_iterate_shim(loop : Loop*, timeout : LibC::Int) : LibC::Int
    fun pw_loop_get_fd = pw_loop_get_fd_shim(loop : Loop*) : LibC::Int
  end
end
