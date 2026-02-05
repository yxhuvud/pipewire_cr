#include <spa/param/audio/format-utils.h>
#include <pipewire/pipewire.h>

struct spa_pod *
spa_format_audio_raw_build_shim(struct spa_pod_builder * builder,
                                uint32_t id,
                                struct spa_audio_info_raw * info) {
  return spa_format_audio_raw_build(builder, id, info);
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
