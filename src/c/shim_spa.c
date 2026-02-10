#include <spa/param/audio/format-utils.h>

struct spa_pod *
spa_format_audio_raw_build_shim(struct spa_pod_builder * builder,
                                uint32_t id,
                                struct spa_audio_info_raw * info) {
  return spa_format_audio_raw_build(builder, id, info);
}
