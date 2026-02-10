require "../src/pipewire"

Pipewire.init("tutorial1")

puts "Compiled with libpipewire #{String.new(Pipewire::LibPipewire.pw_get_headers_version)}"
puts "Linked with libpipewire #{String.new(Pipewire::LibPipewire.pw_get_library_version)}"
