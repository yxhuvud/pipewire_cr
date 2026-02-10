module Pipewire
  @[Link("pipewire-0.3", ldflags: "#{__DIR__}/../../build/shim_spa.o")]
  lib LibSPA
    type Pod = Void
    type PodFrame = Void

    struct PodBuilder
      data : Pointer(Void)
      size : UInt32
      padding : UInt32
      state : PodBuilderState
      callbacks : Callbacks
    end

    @[Flags]
    enum PodBuilderFlags
      None
      Body
      First
    end

    enum Direction
      Input
      Output
    end

    struct PodBuilderState
      offset : UInt32
      flags : PodBuilderFlags
      frame : Pointer(PodFrame)
    end

    struct Callbacks
      funcs : Pointer(Void)
      data : Pointer(Void)
    end

    struct AudioInfoRaw
      format : AudioFormat
      flags : UInt32
      rate : UInt32
      channels : UInt32
      position : UInt32[MAX_CHANNELS]
    end

    MAX_CHANNELS = 64

    fun spa_format_audio_raw_build = spa_format_audio_raw_build_shim(
      builder : PodBuilder*,
      id : ParamType,
      info : AudioInfoRaw*,
    ) : Pod*

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
  end
end
