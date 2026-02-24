require "json"
require "../src/pipewire"

Pipewire.init("monitor_node_params")

main_loop = Pipewire::MainLoop.new
context = main_loop.create_context
core = context.connect
registry = core.registry

nodes = [] of Pipewire::Node

registry.on_global do |node_id, permissions, item_type, version, properties|
  if item_type == "PipeWire:Interface:Node"
    node = registry.bind_node(node_id, item_type)
    nodes << node

    node.on_param do |seq, param_type, index, next_index, param|
      puts param.to_value.to_pretty_json
    end

    node.subscribe_params([
      Pipewire::LibSPA::ParamType::Props,
      Pipewire::LibSPA::ParamType::PropInfo,
    ])
  end
end

main_loop.process_all
