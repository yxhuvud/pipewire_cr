require "../src/pipewire"

Pipewire.init("tutorial6")

main_loop = Pipewire::MainLoop.new
context = main_loop.create_context
core = context.connect
registry = core.registry

client = nil

registry.on_global do |id, permissions, item_type, version, properties|
  if !client && item_type == "PipeWire:Interface:Client"
    client = registry.bind_client(id, item_type)
    client.not_nil!.on_info do |client_info|
      puts "client id:#{id}"
      puts "\tprops:"
      client_info.properties.each do |key, value|
        puts %Q{\t\t#{key}: "#{value}"}
      end

      main_loop.quit
    end
  end
end

main_loop.run
