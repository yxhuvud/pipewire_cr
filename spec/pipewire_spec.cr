require "./spec_helper"

describe Pipewire do
  it "can do a roundtrip" do
    # https://docs.pipewire.org/page_tutorial3.html
    Pipewire.init "hello"
    main_loop = Pipewire::MainLoop.new
    context = main_loop.create_context
    core = context.connect
  end
end
