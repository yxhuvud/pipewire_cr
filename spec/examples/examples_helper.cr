require "spec"
require "process"
require "file_utils"

SOURCE_DIR = File.join(__DIR__, "..", "..", "examples")
BIN_DIR    = File.join(__DIR__, "bincache")

def example_scripts
  Dir[File.join(SOURCE_DIR, "*.cr")].map do |name|
    File.basename(name).chomp(".cr")
  end
end

FileUtils.rm_rf(BIN_DIR)

def example_executable!(name)
  path_source = File.join(SOURCE_DIR, "#{name}.cr")
  path_bin = File.join(BIN_DIR, name)

  raise "Could not find example file #{path_source.inspect}." unless File.exists?(path_source)

  if !File.exists?(path_bin)
    Dir.mkdir_p(BIN_DIR)
    Process.run("/usr/bin/env", ["crystal", "build", "--release", "--output", path_bin, path_source])
  end

  path_bin
end
