require "option_parser"
require "../src/pipewire"

Pipewire.init("pw-metadata.cr")

DEFAULT_METADATA_NAME = "default"

opt_remote_name = nil
opt_list = false
opt_monitor = false
opt_delete = false
opt_name = DEFAULT_METADATA_NAME

parser = OptionParser.parse do |parser|
  parser.banner = "#{PROGRAM_NAME} [options] [ id [ key [ value [ type ] ] ] ]"
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end
  parser.on("-V", "--version", "Show version") do
    puts "Compiled with libpipewire #{Pipewire.headers_version}"
    puts "Linked with libpipewire #{Pipewire.library_version}"
    exit
  end
  parser.on("-r NAME", "--remote=NAME", "Remote daemon name") { |name| opt_remote_name = name }
  parser.on("-l", "--list", "List available metadata") { opt_list = true }
  parser.on("-m", "--monitor", "Monitor metadata") { opt_monitor = true }
  parser.on("-d", "--delete", "Delete metadata") { opt_delete = true }
  parser.on("-n NAME", "--name NAME", "Metadata name (default: \"#{DEFAULT_METADATA_NAME}\")") { |name| opt_name = name }

  parser.invalid_option do
    STDERR.puts parser
    exit -1
  end
end

parser.parse

opt_id = ARGV[0]?.try(&.to_u32)
opt_key = ARGV[1]?
opt_value = ARGV[2]?
opt_type = ARGV[3]?

main_loop = Pipewire::MainLoop.new
context = main_loop.create_context
core = context.connect(
  {
    Pipewire::PropertyKey::REMOTE_NAME => opt_remote_name,
  }
)

sync = 0

core.on_done do |id, seq|
  if seq == sync && !opt_monitor
    main_loop.quit
  end
end

core.on_error do |id, seq, res, message|
  {% if flag?(:warn) %}
    STDERR.puts "error id:#{id} seq:#{seq} res:#{res} (#{Errno.new(res)}): #{message}"
  {% end %}

  if id == Pipewire::LibPipewire::ID_CORE && res == -Errno::EPIPE.value
    main_loop.quit
  end
end

registry = core.registry

cached_metadata = nil

registry.on_global do |object_id, permissions, item_type, version, properties|
  if item_type == "PipeWire:Interface:Metadata"
    props = properties.to_h

    if props.has_key?(Pipewire::PropertyKey::METADATA_NAME.key)
      name = props[Pipewire::PropertyKey::METADATA_NAME.key]

      if (opt_name.empty? || name == opt_name) && (opt_list || cached_metadata.nil?)
        puts "Found \"#{name}\" metadata #{object_id}"

        if !opt_list
          metadata = registry.bind_metadata(object_id)
          cached_metadata = metadata

          if opt_delete
            if opt_id
              if opt_key
                metadata.set_property(opt_id, opt_key, nil, nil)
                puts "delete property: id:#{opt_id} key: #{opt_key}"
              else
                puts "delete properties: id:#{opt_id}"
              end
            else
              puts "delete all properties"
              metadata.clear
            end
          elsif opt_id && opt_key && !opt_value.nil?
            puts "set property: id:#{opt_id} key:#{opt_key} value:#{opt_value} type:#{opt_type}"
            metadata.set_property(opt_id, opt_key, opt_type || "", opt_value.not_nil!)
          else
            metadata.on_property do |md_id, md_key, md_type, md_value|
              if !opt_list && (opt_id.nil? || opt_id == md_id) && (opt_key.nil? || opt_key == md_key)
                if md_key.nil?
                  puts "remove: id:#{md_id} all keys"
                elsif md_value.nil?
                  puts "remove: id:#{md_id} key:'#{md_key}'"
                else
                  puts "update: id:#{md_id} key:'#{md_key}' value:'#{md_value}' type:'#{md_type}'"
                end
              end

              0
            end
          end

          sync = core.sync(sync)
        end
      else
        {% if flag?(:warn) %}
          STDERR.puts("Multiple metadata: ignoring metadata #{object_id}")
        {% end %}
      end
    end
  end
end

sync = core.sync(0)

main_loop.run
