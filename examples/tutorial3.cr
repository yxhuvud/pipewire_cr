require "../src/pipewire"

Pipewire.init("tutorial3")

main_loop = Pipewire::MainLoop.new
context = Pipewire::Context.new(main_loop)
core = context.connect
registry = core.registry

registry.on_global do |id, permissions, item_type, version, properties|
  puts "object: id:#{id} type:#{item_type}/#{version}"
end

pending = core.sync(0)

listener = core.on_done do |id, seq|
  if id == Pipewire::LibPipewire::ID_CORE && seq == pending
    main_loop.quit
  end
end

if (err = main_loop.run) < 0
  puts "main_loop_run error: #{err}"
end

listener.remove
