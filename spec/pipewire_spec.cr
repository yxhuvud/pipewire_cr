require "./spec_helper"

describe Pipewire do
  # based on https://docs.pipewire.org/page_tutorial3.html
  it "can enumerate registry objects" do
    main_loop = Pipewire::MainLoop.new
    context = main_loop.create_context
    core = context.connect
    registry = core.registry

    object_ids = Set(UInt32).new

    registry.on_global do |id, permissions, item_type, version, properties|
      object_ids << id
    end

    pending = core.sync(0)

    core.on_done do |id, seq|
      if id == Pipewire::LibPipewire::ID_CORE && seq == pending
        main_loop.quit
      end
    end

    main_loop.run.should eq 0

    object_ids.size.should be > 0
  end
end
