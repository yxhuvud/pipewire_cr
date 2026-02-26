#include <pipewire/pipewire.h>
#include <pipewire/extensions/metadata.h>

const char* pw_get_headers_version_shim() {
  return pw_get_headers_version();
}

void pw_loop_enter_shim(struct pw_loop *loop) {
  pw_loop_enter(loop);
}

void pw_loop_leave_shim(struct pw_loop * loop) {
  pw_loop_leave(loop);
}

int pw_loop_iterate_shim(struct pw_loop * loop, int timeout) {
  return pw_loop_iterate(loop, timeout);
}

int pw_loop_get_fd_shim(struct pw_loop * loop) {
  return pw_loop_get_fd(loop);
}

int pw_metadata_add_listener_shim(struct pw_metadata *object, struct spa_hook *listener, const struct pw_metadata_events *events, void *data) {
  return pw_metadata_add_listener(object, listener, events, data);
}

int pw_metadata_set_property_shim(struct pw_metadata *object, uint32_t subject, const char *key, const char *type, const char *value) {
  return pw_metadata_set_property(object, subject, key, type, value);
}

int pw_metadata_clear_shim(struct pw_metadata *object) {
  return pw_metadata_clear(object);
}
