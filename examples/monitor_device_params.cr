require "json"
require "../src/pipewire"

Pipewire.init("monitor_device_params")

main_loop = Pipewire::MainLoop.new
context = main_loop.create_context
core = context.connect
registry = core.registry

registry.on_global do |device_id, permissions, item_type, version, properties|
  if item_type == "PipeWire:Interface:Device"
    device = registry.bind_device(device_id, item_type)

    device.on_param do |seq, param_type, index, next_index, param|
      puts param.to_value.to_pretty_json
    end

    device.subscribe_params([
      Pipewire::LibSPA::ParamType::Profile,
      Pipewire::LibSPA::ParamType::Route,
    ])
  end
end

main_loop.process_all
