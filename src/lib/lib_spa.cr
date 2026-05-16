module Pipewire
  @[Link("pipewire-0.3", ldflags: "#{__DIR__}/../../build/shim_spa.o")]
  lib LibSPA
    MAX_CHANNELS =         64
    ID_INVALID   = 0xffffffff
    POD_ALIGN    =          8

    @[Flags]
    enum PodBuilderFlag
      Body
      First
    end

    enum Direction
      Input
      Output
    end

    # defined in param.h. Deviates typewise to avoid having to cast the value everywhere.
    enum ParamType : UInt32
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

    # defined in param/route.h, used together with ParamType::Route
    enum ParamRoute
      START
      Index
      Direction
      Device
      Name
      Description
      Priority
      Available
      Info
      Profiles
      Props
      Devices
      Profile
      Save
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

    enum VideoFormat
      UNKNOWN
      ENCODED

      I420
      YV12
      YUY2
      UYVY
      AYUV
      RGBX
      BGRX
      XRGB
      XBGR
      RGBA
      BGRA
      ARGB
      ABGR
      RGB
      BGR
      Y41B
      Y42B
      YVYU
      Y444
      V210
      V216
      NV12
      NV21
      GRAY8
      GRAY16_BE
      GRAY16_LE
      V308
      RGB16
      BGR16
      RGB15
      BGR15
      UYVP
      A420
      RGB8P
      YUV9
      YVU9
      IYU1
      ARGB64
      AYUV64
      R210
      I420_10BE
      I420_10LE
      I422_10BE
      I422_10LE
      Y444_10BE
      Y444_10LE
      GBR
      GBR_10BE
      GBR_10LE
      NV16
      NV24
      NV12_64Z32
      A420_10BE
      A420_10LE
      A422_10BE
      A422_10LE
      A444_10BE
      A444_10LE
      NV61
      P010_10BE
      P010_10LE
      IYU2
      VYUY
      GBRA
      GBRA_10BE
      GBRA_10LE
      GBR_12BE
      GBR_12LE
      GBRA_12BE
      GBRA_12LE
      I420_12BE
      I420_12LE
      I422_12BE
      I422_12LE
      Y444_12BE
      Y444_12LE

      RGBA_F16
      RGBA_F32

      XRGB_210LE
      XBGR_210LE
      RGBx_102LE
      BGRx_102LE
      ARGB_210LE
      ABGR_210LE
      RGBA_102LE
      BGRA_102LE

      DSP_F32 = RGBA_F32
    end

    # defined in pod.h. Deviates typewise to avoid having to cast the value everywhere.
    enum PodType : UInt32
      START     = 0x00000
      None
      Bool
      Id
      Int
      Long
      Float
      Double
      String
      Bytes
      Rectangle
      Fraction
      Bitmap
      Array
      Struct
      Object
      Sequence
      Pointer
      Fd
      Choice
      Pod
    end

    # Defined in pod.h. Deviates typewise to avoid having to cast the value everywhere.
    enum PodObjectType : UInt32
      START               = 0x40000
      PropInfo
      Props
      Format
      ParamBuffers
      ParamMeta
      ParamIO
      ParamProfile
      ParamPortConfig
      ParamRoute
      Profiler
      ParamLatency
      ParamProcessLatency
      ParamTag
      PeerParam
      ParamDict
    end

    # defined in pod.h. Deviates typewise to avoid having to cast the value everywhere.
    enum Choice : UInt32
      None
      Range
      Step
      Enum
      Flags
    end

    @[Flags]
    enum PropFlag
      Readonly
      Hardware
      HintDict
      Mandatory
      DontFixate
      Drop
    end

    enum ControlType
      Invalid
      Properties
      Midi
      OSC
      UMP
    end

    # defined in props.h. Used together with PodObjectType::Props
    enum Prop
      START

      Unknown

      START_Device = 0x100
      Device
      DeviceName
      DeviceFd
      Card
      CardName

      MinLatency
      MaxLatency
      Periods
      PeriodSize
      PeriodEvent
      Live
      Rate
      Quality
      BluetoothAudioCodec
      BluetoothOffloadActive
      ClockId
      ClockDevice
      ClockInterface

      START_Audio       = 0x10000
      WaveType
      Frequency
      Volume
      Mute
      PatternType
      DitherType
      Truncate
      ChannelVolumes
      VolumeBase
      VolumeStep
      ChannelMap
      MonitorMute
      MonitorVolumes
      LatencyOffsetNsec
      SoftMute
      SoftVolumes

      Iec958Codecs
      VolumeRampSamples
      VolumeRampStepSamples
      VolumeRampTime
      VolumeRampStepTime
      VolumeRampScale

      START_Video = 0x20000
      Brightness
      Contrast
      Saturation
      Hue
      Gamma
      Exposure
      Gain
      Sharpness

      START_Other = 0x80000
      Params

      START_CUSTOM = 0x1000000
    end

    # defined in format.h. Used together with PodObjectType::Format
    enum Format
      START

      MediaType
      MediaSubtype
      START_Audio    = 0x10000
      AUDIO_format
      AUDIO_flags
      AUDIO_rate
      AUDIO_channels
      AUDIO_position

      AUDIO_iec958Codec

      AUDIO_bitorder
      AUDIO_interleave
      AUDIO_bitrate
      AUDIO_blockAlign

      AUDIO_AAC_streamFormat

      AUDIO_WMA_profile

      AUDIO_AMR_bandMode

      AUDIO_MP3_channelMode

      AUDIO_DTS_extType
      START_Video       = 0x20000
      VIDEO_format
      VIDEO_modifier

      VIDEO_size
      VIDEO_framerate
      VIDEO_maxFramerate
      VIDEO_views
      VIDEO_interlaceMode
      VIDEO_pixelAspectRatio
      VIDEO_multiviewMode
      VIDEO_multiviewFlags
      VIDEO_chromaSite
      VIDEO_colorRange
      VIDEO_colorMatrix
      VIDEO_transferFunction
      VIDEO_colorPrimaries
      VIDEO_profile
      VIDEO_level
      VIDEO_H264_streamFormat
      VIDEO_H264_alignment
      VIDEO_H265_streamFormat
      VIDEO_H265_alignment

      START_Image       = 0x30000
      START_Binary      = 0x40000
      START_Stream      = 0x50000
      START_Application = 0x60000
      CONTROL_types
    end

    # defined in format.h, used in props with Format::MediaType as key
    enum MediaType
      Unknown
      Audio
      Video
      Image
      Binary
      Stream
      Application
    end

    # defined in format.h, used in props with Format::MediaSubType as key
    enum MediaSubType
      Unknown
      Raw
      Dsp
      Iec958
      Dsd

      START_Audio = 0x10000
      Mp3
      Aac
      Vorbis
      Wma
      Ra
      Sbc
      Adpcm
      G723
      G726
      G729
      Amr
      Gsm
      Alac
      Flac
      Ape
      Opus
      Ac3
      Eac3
      Truehd
      Dts
      Mpegh

      START_Video = 0x20000
      H264
      Mjpg
      Dv
      Mpegts
      H263
      Mpeg1
      Mpeg2
      Mpeg4
      Xvid
      Vc1
      Vp8
      Vp9
      Bayer
      H265

      START_Image = 0x30000
      Jpeg

      START_Binary = 0x40000

      START_Stream = 0x50000
      Midi

      START_Application = 0x60000
      Control
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
      type : PodType
    end

    struct PodBool
      pod : Pod
      value : Int32
      _padding : Int32
    end

    struct PodId
      pod : Pod
      value : UInt32
      _padding : Int32
    end

    struct PodInt
      pod : Pod
      value : Int32
      _padding : Int32
    end

    struct PodLong
      pod : Pod
      value : Int64
    end

    struct PodFloat
      pod : Pod
      value : Float32
      _padding : Int32
    end

    struct PodDouble
      pod : Pod
      value : Float64
    end

    struct PodString
      pod : Pod
    end

    struct PodBytes
      pod : Pod
    end

    struct Rectangle
      width : UInt32
      height : UInt32
    end

    struct PodRectangle
      pod : Pod
      value : Rectangle
    end

    struct Fraction
      numerator : UInt32
      denominator : UInt32
    end

    struct PodFraction
      pod : Pod
      value : Fraction
    end

    struct PodBitmap
      pod : Pod
    end

    struct PodArrayBody
      child : Pod
    end

    struct PodArray
      pod : Pod
      body : PodArrayBody
    end

    struct PodChoiceBody
      type : UInt32
      flags : UInt32
      child : Pod
    end

    struct PodChoice
      pod : Pod
      body : PodChoiceBody
    end

    struct PodStruct
      pod : Pod
    end

    struct PodObjectBody
      type : PodObjectType
      id : UInt32
    end

    struct PodObject
      pod : Pod
      body : PodObjectBody
    end

    struct PodPointerBody
      type : PodType
      _padding : UInt32
      value : Void*
    end

    struct PodPointer
      pod : Pod
      body : PodPointerBody
    end

    struct PodFd
      pod : Pod
      value : Int64
    end

    struct PodProp
      key : Prop
      flags : PropFlag
      value : Pod
    end

    struct PodControl
      offset : UInt32
      type : ControlType
      value : Pod
    end

    struct PodSequenceBody
      unit : UInt32
      pad : UInt32
    end

    struct PodSequence
      pod : Pod
      body : PodSequenceBody
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

    struct ParamInfo
      id : ParamType
      flags : UInt32
      user : UInt32
      seq : Int32
      padding : UInt32[4]
    end

    struct TypeInfo
      type : UInt32
      parent : UInt32
      name : LibC::Char*
      values : TypeInfo*
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

    fun spa_hook_remove = spa_hook_remove_shim(hook : Hook*) : Void

    fun spa_shim_type_root : TypeInfo*
  end
end
