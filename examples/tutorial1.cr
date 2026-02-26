require "../src/pipewire"

Pipewire.init("tutorial1")

puts "Compiled with libpipewire #{Pipewire.headers_version}"
puts "Linked with libpipewire #{Pipewire.library_version}"
