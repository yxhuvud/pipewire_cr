module Pipewire
  module EventListener
    macro event_listener(callback)
      {% callback_name = callback.var %}
      {% callback_type = callback.type %}
      {% type_name = @type.name.split("::").last.id %}
      {% events_type = parse_type("Pipewire::LibPipewire::#{type_name}Events").resolve %}

      def on_{{ callback_name }}(&callback : {{ callback_type }})
        EventListener{{ callback_name.camelcase }}.new(self, callback).tap do |event_listener|
          self.event_listeners_{{ callback_name }} << event_listener
        end
      end

      protected getter event_listeners_{{ callback_name }} = [] of EventListener{{ callback_name.camelcase }}

      class EventListener{{ callback_name.camelcase }}
        def initialize(@host : {{ @type }}, callback : {{ callback_type }})
          @hook = ::Pipewire::LibSPA::Hook.new
          @box = ::Box.box(callback)
          @events = {{ events_type }}.new(
            version: {{ @type }}::EVENT_LISTENER_VERSION,
            {{ callback_name }}: ->(data : Void*,
              {% for unresolved_type, i in callback_type.inputs %}
                {% t = unresolved_type.resolve %}
                arg{{ i }} : {% if (t.name.starts_with?("Pipewire::LibPipewire::") || t.name.starts_with?("Pipewire::LibSPA::")) && !(t <= Enum) %}
                    {{ t }}*,
                  {% elsif t <= parse_type("Pipewire::Base").resolve %}
                    {{ t.ancestors.find { |a| a.name(generic_args: false) == "Pipewire::Base" }.type_vars.first }}*,
                  {% elsif t.resolve == String %}
                    LibC::Char*,
                  {% else %}
                    {{ t }},
                  {% end %}
              {% end %}
            ) do
            cb = Box(typeof(callback)).unbox(data)
            cb.call(
              {% for unresolved_type, i in callback_type.inputs %}
                {% t = unresolved_type.resolve %}
                {% if (t.name.starts_with?("Pipewire::LibPipewire::") || t.name.starts_with?("Pipewire::LibSPA::")) && !(t <= Enum) %}
                  arg{{ i }}.value,
                {% elsif t <= parse_type("Pipewire::Base").resolve %}
                  {{ t }}.new(arg{{ i }}),
                {% elsif t.resolve == String %}
                  String.new(arg{{ i }}),
                {% else %}
                  arg{{ i }},
                {% end %}
              {% end %}
            )
          end)

          LibPipewire.pw_{{ type_name.downcase }}_add_listener(@host, pointerof(@hook), pointerof(@events), @box)
        end

        def remove
          @host.event_listeners_{{ callback_name }}.delete(self)
          ::Pipewire::LibSPA.spa_hook_remove(pointerof(@hook))
        end
      end
    end
  end
end
