require "spec"
require "process"
require "digest/sha256"

SOURCE_DIR = File.join(__DIR__, "..", "..", "examples")
BIN_DIR    = File.join(__DIR__, "bincache")

def example_scripts
  Dir[File.join(SOURCE_DIR, "*.cr")].map do |name|
    File.basename(name).chomp(".cr")
  end
end

def example_executable!(name)
  filename_source = "#{name}.cr"
  fullpath_source = File.join(SOURCE_DIR, filename_source)

  raise "Could not find example file #{filename_source.inspect}." unless File.exists?(fullpath_source)

  digest = Digest::SHA256.new
  digest.file(fullpath_source)
  filename_bin = "#{name}_#{digest.hexfinal}"
  fullpath_bin = File.join(BIN_DIR, filename_bin)

  if !File.exists?(fullpath_bin)
    Dir.mkdir_p(BIN_DIR)
    Process.run("/usr/bin/env", ["crystal", "build", "--release", "--output", fullpath_bin, fullpath_source])
  end

  fullpath_bin
end
