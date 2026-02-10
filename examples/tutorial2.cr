require "../src/pipewire"

Pipewire.init("tutorial2")

main_loop = Pipewire::MainLoop.new
context = Pipewire::Context.new(main_loop)
core = context.connect
registry = core.registry

registry.on_global do |id, permissions, item_type, version, properties|
  puts "object: id:#{id} type:#{item_type}/#{version}"
end

main_loop.run
