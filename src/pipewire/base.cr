module Pipewire
  abstract class Base(T)
    @pointer : T*

    def initialize(@pointer : T*)
    end

    def to_unsafe
      @pointer
    end
  end
end
