require "json"
require "../src/pipewire"

Pipewire.init("pw-dump.cr")

main_loop = Pipewire::MainLoop.new
context = main_loop.create_context
core = context.connect
registry = core.registry

class PWObject
  property id : UInt32
  property permissions : Pipewire::LibPipewire::Perm
  property type : String
  property version : UInt32
  property properties : Hash(String, String?)

  def initialize(@id, @permissions, @type, @version, @properties)
  end

  def to_json(builder : JSON::Builder)
    builder.object do
      builder.field("id", self.id)
      builder.field("type", self.type)
      builder.field("version", self.version)
      builder.field("permissions") do
        builder.array do
          builder.scalar("r") if self.permissions.read?
          builder.scalar("w") if self.permissions.write?
          builder.scalar("x") if self.permissions.execute?
          builder.scalar("m") if self.permissions.metadata?
          builder.scalar("l") if self.permissions.link?
        end
      end
      if self.properties.any?
        builder.field("props") do
          builder.object do
            self.properties.each do |key, value|
              builder.field(key) do
                if value.nil?
                  builder.null
                elsif value == "true"
                  builder.scalar(true)
                elsif value == "false"
                  builder.scalar(false)
                elsif (int = value.to_i64?(strict: true))
                  builder.scalar(int)
                elsif (float = value.to_f64?(strict: true))
                  builder.scalar(float)
                else
                  builder.scalar(value)
                end
              end
            end
          end
        end
      end
    end
  end
end

pw_objects = [] of PWObject

sync_seq = core.sync(0)

registry.on_global do |id, permissions, item_type, version, properties|
  pw_objects << PWObject.new(id, permissions, item_type, version, properties.to_h)

  case item_type
  when "PipeWire:Interface:Node"
    node = registry.bind_node(id, item_type)

    node.on_info do |node_info|
      node_info
    end
  end

  sync_seq = core.sync(0)
end

core.on_done do |id, seq|
  if id == Pipewire::LibPipewire::ID_CORE && seq == sync_seq
    puts pw_objects.to_pretty_json

    main_loop.quit
  end
end

if (err = main_loop.run) < 0
  puts "main_loop_run error: #{err}"
end
