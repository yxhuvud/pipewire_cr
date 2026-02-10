module Pipewire
  @[Link("pipewire-0.3", ldflags: "#{__DIR__}/../../build/shim_spa.o")]
  lib LibSPA
    type SpaPod = Void
    type SpaPodFrame = Void

    struct SpaPodBuilder
      data : Pointer(Void)
      size : UInt32
      padding : UInt32
      state : SpaPodBuilderState
      callbacks : SpaCallbacks
    end

    @[Flags]
    enum SpaPodBuilderFlags
      None
      Body
      First
    end

    enum Direction
      Input
      Output
    end

    struct SpaPodBuilderState
      offset : UInt32
      flags : SpaPodBuilderFlags
      frame : Pointer(SpaPodFrame)
    end

    struct SpaCallbacks
      funcs : Pointer(Void)
      data : Pointer(Void)
    end

    struct SpaAudioInfoRaw
      format : SpaAudioFormat
      flags : UInt32
      rate : UInt32
      channels : UInt32
      position : UInt32[MAX_CHANNELS]
    end

    MAX_CHANNELS = 64

    fun spa_format_audio_raw_build = spa_format_audio_raw_build_shim(
      builder : SpaPodBuilder*,
      id : SpaParamType,
      info : SpaAudioInfoRaw*,
    ) : SpaPod*

    enum SpaParamType
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

    enum SpaAudioFormat
      SPA_AUDIO_FORMAT_UNKNOWN
      SPA_AUDIO_FORMAT_ENCODED

      # /* interleaved formats */
      SPA_AUDIO_FORMAT_START_Interleaved = 0x100
      SPA_AUDIO_FORMAT_S8
      SPA_AUDIO_FORMAT_U8
      SPA_AUDIO_FORMAT_S16_LE
      SPA_AUDIO_FORMAT_S16_BE
      SPA_AUDIO_FORMAT_U16_LE
      SPA_AUDIO_FORMAT_U16_BE
      SPA_AUDIO_FORMAT_S24_32_LE
      SPA_AUDIO_FORMAT_S24_32_BE
      SPA_AUDIO_FORMAT_U24_32_LE
      SPA_AUDIO_FORMAT_U24_32_BE
      SPA_AUDIO_FORMAT_S32_LE
      SPA_AUDIO_FORMAT_S32_BE
      SPA_AUDIO_FORMAT_U32_LE
      SPA_AUDIO_FORMAT_U32_BE
      SPA_AUDIO_FORMAT_S24_LE
      SPA_AUDIO_FORMAT_S24_BE
      SPA_AUDIO_FORMAT_U24_LE
      SPA_AUDIO_FORMAT_U24_BE
      SPA_AUDIO_FORMAT_S20_LE
      SPA_AUDIO_FORMAT_S20_BE
      SPA_AUDIO_FORMAT_U20_LE
      SPA_AUDIO_FORMAT_U20_BE
      SPA_AUDIO_FORMAT_S18_LE
      SPA_AUDIO_FORMAT_S18_BE
      SPA_AUDIO_FORMAT_U18_LE
      SPA_AUDIO_FORMAT_U18_BE
      SPA_AUDIO_FORMAT_F32_LE
      SPA_AUDIO_FORMAT_F32_BE
      SPA_AUDIO_FORMAT_F64_LE
      SPA_AUDIO_FORMAT_F64_BE

      SPA_AUDIO_FORMAT_ULAW
      SPA_AUDIO_FORMAT_ALAW

      #        /* planar formats */
      SPA_AUDIO_FORMAT_START_Planar = 0x200
      SPA_AUDIO_FORMAT_U8P
      SPA_AUDIO_FORMAT_S16P
      SPA_AUDIO_FORMAT_S24_32P
      SPA_AUDIO_FORMAT_S32P
      SPA_AUDIO_FORMAT_S24P
      SPA_AUDIO_FORMAT_F32P
      SPA_AUDIO_FORMAT_F64P
      SPA_AUDIO_FORMAT_S8P

      #       /* other formats start here */
      SPA_AUDIO_FORMAT_START_Other = 0x400

      #      /* Aliases */

      #     /* DSP formats */
      SPA_AUDIO_FORMAT_DSP_S32 = SPA_AUDIO_FORMAT_S24_32P
      SPA_AUDIO_FORMAT_DSP_F32 = SPA_AUDIO_FORMAT_F32P
      SPA_AUDIO_FORMAT_DSP_F64 = SPA_AUDIO_FORMAT_F64P

      # #if __BYTE_ORDER == __BIG_ENDIAN
      #         SPA_AUDIO_FORMAT_S16 = SPA_AUDIO_FORMAT_S16_BE
      #         SPA_AUDIO_FORMAT_U16 = SPA_AUDIO_FORMAT_U16_BE
      #         SPA_AUDIO_FORMAT_S24_32 = SPA_AUDIO_FORMAT_S24_32_BE
      #         SPA_AUDIO_FORMAT_U24_32 = SPA_AUDIO_FORMAT_U24_32_BE
      #         SPA_AUDIO_FORMAT_S32 = SPA_AUDIO_FORMAT_S32_BE
      #         SPA_AUDIO_FORMAT_U32 = SPA_AUDIO_FORMAT_U32_BE
      #         SPA_AUDIO_FORMAT_S24 = SPA_AUDIO_FORMAT_S24_BE
      #         SPA_AUDIO_FORMAT_U24 = SPA_AUDIO_FORMAT_U24_BE
      #         SPA_AUDIO_FORMAT_S20 = SPA_AUDIO_FORMAT_S20_BE
      #         SPA_AUDIO_FORMAT_U20 = SPA_AUDIO_FORMAT_U20_BE
      #         SPA_AUDIO_FORMAT_S18 = SPA_AUDIO_FORMAT_S18_BE
      #         SPA_AUDIO_FORMAT_U18 = SPA_AUDIO_FORMAT_U18_BE
      #         SPA_AUDIO_FORMAT_F32 = SPA_AUDIO_FORMAT_F32_BE
      #         SPA_AUDIO_FORMAT_F64 = SPA_AUDIO_FORMAT_F64_BE
      #         SPA_AUDIO_FORMAT_S16_OE = SPA_AUDIO_FORMAT_S16_LE
      #         SPA_AUDIO_FORMAT_U16_OE = SPA_AUDIO_FORMAT_U16_LE
      #         SPA_AUDIO_FORMAT_S24_32_OE = SPA_AUDIO_FORMAT_S24_32_LE
      #         SPA_AUDIO_FORMAT_U24_32_OE = SPA_AUDIO_FORMAT_U24_32_LE
      #         SPA_AUDIO_FORMAT_S32_OE = SPA_AUDIO_FORMAT_S32_LE
      #         SPA_AUDIO_FORMAT_U32_OE = SPA_AUDIO_FORMAT_U32_LE
      #         SPA_AUDIO_FORMAT_S24_OE = SPA_AUDIO_FORMAT_S24_LE
      #         SPA_AUDIO_FORMAT_U24_OE = SPA_AUDIO_FORMAT_U24_LE
      #         SPA_AUDIO_FORMAT_S20_OE = SPA_AUDIO_FORMAT_S20_LE
      #         SPA_AUDIO_FORMAT_U20_OE = SPA_AUDIO_FORMAT_U20_LE
      #         SPA_AUDIO_FORMAT_S18_OE = SPA_AUDIO_FORMAT_S18_LE
      #         SPA_AUDIO_FORMAT_U18_OE = SPA_AUDIO_FORMAT_U18_LE
      #         SPA_AUDIO_FORMAT_F32_OE = SPA_AUDIO_FORMAT_F32_LE
      #         SPA_AUDIO_FORMAT_F64_OE = SPA_AUDIO_FORMAT_F64_LE
      # #elif __BYTE_ORDER == __LITTLE_ENDIAN
      SPA_AUDIO_FORMAT_S16       = SPA_AUDIO_FORMAT_S16_LE
      SPA_AUDIO_FORMAT_U16       = SPA_AUDIO_FORMAT_U16_LE
      SPA_AUDIO_FORMAT_S24_32    = SPA_AUDIO_FORMAT_S24_32_LE
      SPA_AUDIO_FORMAT_U24_32    = SPA_AUDIO_FORMAT_U24_32_LE
      SPA_AUDIO_FORMAT_S32       = SPA_AUDIO_FORMAT_S32_LE
      SPA_AUDIO_FORMAT_U32       = SPA_AUDIO_FORMAT_U32_LE
      SPA_AUDIO_FORMAT_S24       = SPA_AUDIO_FORMAT_S24_LE
      SPA_AUDIO_FORMAT_U24       = SPA_AUDIO_FORMAT_U24_LE
      SPA_AUDIO_FORMAT_S20       = SPA_AUDIO_FORMAT_S20_LE
      SPA_AUDIO_FORMAT_U20       = SPA_AUDIO_FORMAT_U20_LE
      SPA_AUDIO_FORMAT_S18       = SPA_AUDIO_FORMAT_S18_LE
      SPA_AUDIO_FORMAT_U18       = SPA_AUDIO_FORMAT_U18_LE
      SPA_AUDIO_FORMAT_F32       = SPA_AUDIO_FORMAT_F32_LE
      SPA_AUDIO_FORMAT_F64       = SPA_AUDIO_FORMAT_F64_LE
      SPA_AUDIO_FORMAT_S16_OE    = SPA_AUDIO_FORMAT_S16_BE
      SPA_AUDIO_FORMAT_U16_OE    = SPA_AUDIO_FORMAT_U16_BE
      SPA_AUDIO_FORMAT_S24_32_OE = SPA_AUDIO_FORMAT_S24_32_BE
      SPA_AUDIO_FORMAT_U24_32_OE = SPA_AUDIO_FORMAT_U24_32_BE
      SPA_AUDIO_FORMAT_S32_OE    = SPA_AUDIO_FORMAT_S32_BE
      SPA_AUDIO_FORMAT_U32_OE    = SPA_AUDIO_FORMAT_U32_BE
      SPA_AUDIO_FORMAT_S24_OE    = SPA_AUDIO_FORMAT_S24_BE
      SPA_AUDIO_FORMAT_U24_OE    = SPA_AUDIO_FORMAT_U24_BE
      SPA_AUDIO_FORMAT_S20_OE    = SPA_AUDIO_FORMAT_S20_BE
      SPA_AUDIO_FORMAT_U20_OE    = SPA_AUDIO_FORMAT_U20_BE
      SPA_AUDIO_FORMAT_S18_OE    = SPA_AUDIO_FORMAT_S18_BE
      SPA_AUDIO_FORMAT_U18_OE    = SPA_AUDIO_FORMAT_U18_BE
      SPA_AUDIO_FORMAT_F32_OE    = SPA_AUDIO_FORMAT_F32_BE
      SPA_AUDIO_FORMAT_F64_OE    = SPA_AUDIO_FORMAT_F64_BE
    end
  end
end
