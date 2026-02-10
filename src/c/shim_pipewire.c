#include <pipewire/pipewire.h>

const char* pw_get_headers_version_shim() {
  return pw_get_headers_version();
}

void
pw_loop_enter_shim(struct pw_loop *loop) {
  pw_loop_enter(loop);
  return;
}

void
pw_loop_leave_shim(struct pw_loop * loop) {
  pw_loop_leave(loop);
  return;
}


int
pw_loop_iterate_shim(struct pw_loop * loop, int timeout) {
  return pw_loop_iterate(loop, timeout);
}

int
pw_loop_get_fd_shim(struct pw_loop * loop) {
  return pw_loop_get_fd(loop);
}
