#!/usr/bin/env crystal

require "process"

TEST_IMAGE_NAME = "crystal_pipewire_test"

container_runtime = Process.find_executable("podman") || Process.find_executable("docker")

unless container_runtime
  STDERR.puts %q{Could not find executables "podman" or "docker".}
  exit 1
end

root_dir = File.expand_path(File.join(__DIR__, ".."))

build_result = Process.run(container_runtime, ["build", "-f", File.join(root_dir, "spec", "Dockerfile"), "-t", TEST_IMAGE_NAME, root_dir], output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
exit build_result.exit_code unless build_result.success?

run_result = Process.run(container_runtime, ["run", "--rm", "--tty", "--volume", "#{root_dir}:/app:O", TEST_IMAGE_NAME, "/bin/bash", "-c", <<-COMMAND], output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
  dbus-daemon --system --fork
  pipewire &
  crystal spec --stats --progress -Dspec_in_container
  COMMAND

exit run_result.exit_code
