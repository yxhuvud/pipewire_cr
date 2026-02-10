module Pipewire
  @[Link("pipewire-0.3", ldflags: "#{__DIR__}/../../build/shim_spa.o")]
  lib LibSPA
    MAX_CHANNELS = 64

    @[Flags]
    enum PodBuilderFlag
      Body
      First
    end

    enum Direction
      Input
      Output
    end

    enum ParamType
      Invalid
      PropInfo
      Props
      EnumFormat
      Format
      Buffers
      Meta
      IO
      EnumProfile
      Profile
      EnumPortConfig
      PortConfig
      EnumRoute
      Route
      Control
      Latency
      ProcessLatency
      Tag
    end

    enum AudioFormat
      UNKNOWN
      ENCODED

      # /* interleaved formats */
      START_Interleaved = 0x100
      S8
      U8
      S16_LE
      S16_BE
      U16_LE
      U16_BE
      S24_32_LE
      S24_32_BE
      U24_32_LE
      U24_32_BE
      S32_LE
      S32_BE
      U32_LE
      U32_BE
      S24_LE
      S24_BE
      U24_LE
      U24_BE
      S20_LE
      S20_BE
      U20_LE
      U20_BE
      S18_LE
      S18_BE
      U18_LE
      U18_BE
      F32_LE
      F32_BE
      F64_LE
      F64_BE

      ULAW
      ALAW

      #        /* planar formats */
      START_Planar = 0x200
      U8P
      S16P
      S24_32P
      S32P
      S24P
      F32P
      F64P
      S8P

      #       /* other formats start here */
      START_Other = 0x400

      #      /* Aliases */

      #     /* DSP formats */
      DSP_S32 = S24_32P
      DSP_F32 = F32P
      DSP_F64 = F64P

      # #if __BYTE_ORDER == __BIG_ENDIAN
      #         S16 = S16_BE
      #         U16 = U16_BE
      #         S24_32 = S24_32_BE
      #         U24_32 = U24_32_BE
      #         S32 = S32_BE
      #         U32 = U32_BE
      #         S24 = S24_BE
      #         U24 = U24_BE
      #         S20 = S20_BE
      #         U20 = U20_BE
      #         S18 = S18_BE
      #         U18 = U18_BE
      #         F32 = F32_BE
      #         F64 = F64_BE
      #         S16_OE = S16_LE
      #         U16_OE = U16_LE
      #         S24_32_OE = S24_32_LE
      #         U24_32_OE = U24_32_LE
      #         S32_OE = S32_LE
      #         U32_OE = U32_LE
      #         S24_OE = S24_LE
      #         U24_OE = U24_LE
      #         S20_OE = S20_LE
      #         U20_OE = U20_LE
      #         S18_OE = S18_LE
      #         U18_OE = U18_LE
      #         F32_OE = F32_LE
      #         F64_OE = F64_LE
      # #elif __BYTE_ORDER == __LITTLE_ENDIAN
      S16       = S16_LE
      U16       = U16_LE
      S24_32    = S24_32_LE
      U24_32    = U24_32_LE
      S32       = S32_LE
      U32       = U32_LE
      S24       = S24_LE
      U24       = U24_LE
      S20       = S20_LE
      U20       = U20_LE
      S18       = S18_LE
      U18       = U18_LE
      F32       = F32_LE
      F64       = F64_LE
      S16_OE    = S16_BE
      U16_OE    = U16_BE
      S24_32_OE = S24_32_BE
      U24_32_OE = U24_32_BE
      S32_OE    = S32_BE
      U32_OE    = U32_BE
      S24_OE    = S24_BE
      U24_OE    = U24_BE
      S20_OE    = S20_BE
      U20_OE    = U20_BE
      S18_OE    = S18_BE
      U18_OE    = U18_BE
      F32_OE    = F32_BE
      F64_OE    = F64_BE
    end

    struct DictItem
      key : LibC::Char*
      value : LibC::Char*
    end

    struct Dict
      flags : UInt32
      n_items : UInt32
      items : DictItem*
    end

    struct List
      next_item : List*
      previous_item : List*
    end

    struct Hook
      link : List
      callbacks : Callbacks
      removed : Hook* -> Void
      priv : Void*
    end

    struct Pod
      size : UInt32
      pod_type : UInt32
    end

    struct PodFrame
      pod : Pod
      parent : PodFrame*
      offset : UInt32
      flags : UInt32
    end

    struct PodBuilderState
      offset : UInt32
      flags : PodBuilderFlag
      frame : Pointer(PodFrame)
    end

    struct Callbacks
      funcs : Pointer(Void)
      data : Pointer(Void)
    end

    struct PodBuilder
      data : Pointer(Void)
      size : UInt32
      padding : UInt32
      state : PodBuilderState
      callbacks : Callbacks
    end

    struct Meta
      meta_type : UInt32
      size : UInt32
      data : Void*
    end

    struct Chunk
      offset : UInt32
      size : UInt32
      stride : Int32
      flags : Int32
    end

    struct Data
      data_type : UInt32
      flags : UInt32
      fd : Int64
      mapoffset : UInt32
      maxsize : UInt32
      data : Void*
      chunk : Chunk*
    end

    struct Buffer
      n_metas : UInt32
      n_datas : UInt32
      metas : Meta*
      datas : Data*
    end

    struct PodObjectBody
      object_type : UInt32
      id : UInt32
    end

    struct CommandBody
      body : PodObjectBody
    end

    struct Command
      pod : Pod
      body : CommandBody
    end

    struct AudioInfoRaw
      format : AudioFormat
      flags : UInt32
      rate : UInt32
      channels : UInt32
      position : UInt32[MAX_CHANNELS]
    end

    fun spa_pod_builder_push_object = spa_pod_builder_push_object_shim(builder : PodBuilder*, frame : PodFrame*, type : UInt32, id : UInt32) : Int32
    fun spa_pod_builder_prop = spa_pod_builder_prop_shim(builder : PodBuilder*, key : UInt32, flags : UInt32) : Int32
    fun spa_pod_get_array_values = spa_pod_get_array_values_shim(pod : Pod*, n_values : UInt32*) : Void*
    fun spa_pod_is_array = spa_pod_is_array_shim(pod : Pod*) : Int32

    fun spa_format_audio_raw_build = spa_format_audio_raw_build_shim(
      builder : PodBuilder*,
      id : UInt32,
      info : AudioInfoRaw*,
    ) : Pod*
  end
end
