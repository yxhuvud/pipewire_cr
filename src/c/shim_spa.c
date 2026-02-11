#include <spa/pod/builder.h>
#include <spa/param/audio/format-utils.h>

struct spa_pod *
spa_format_audio_raw_build_shim(struct spa_pod_builder * builder,
                                uint32_t id,
                                struct spa_audio_info_raw * info) {
  return spa_format_audio_raw_build(builder, id, info);
}

int spa_pod_is_array_shim(const struct spa_pod *pod) {
	return spa_pod_is_array(pod);
}

int spa_pod_builder_push_object_shim(struct spa_pod_builder *builder, struct spa_pod_frame *frame, uint32_t type, uint32_t id) {
	return spa_pod_builder_push_object(builder, frame, type, id);
}

int spa_pod_builder_prop_shim(struct spa_pod_builder *builder, uint32_t key, uint32_t flags) {
	return spa_pod_builder_prop(builder, key, flags);
}

void spa_hook_remove_shim(struct spa_hook *hook) {
  return spa_hook_remove(hook);
}
