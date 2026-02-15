require "../src/pipewire"

Pipewire.init("enumerate_nodes")

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
      if param.pod_type == Pipewire::LibSPA::PodType::Object
        p0 = pointerof(param)
        p1 = p0.as(Pipewire::LibSPA::PodObject*)
        p2 = (p1 + 1).as(Pipewire::LibSPA::PodProp*)

        puts "node #{node_id} param_id:#{param_type} as pod object:#{p1.value}"
        puts "\t#{p2.value}"
      else
        puts "node #{node_id} with unexpected pod type #{param.pod_type}"
      end
    end

    node.on_info do |node_info|
      puts "node_info node:#{node_info.id} n_params:#{node_info.value.n_params}"
      node_info.params.each do |param_info|
        puts "\t#{param_info.id} seq:#{param_info.seq}"
      end
    end

    node.subscribe_params([Pipewire::LibSPA::ParamType::PropInfo])
  end
end

main_loop.run
