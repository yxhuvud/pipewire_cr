require "../../../spec_helper"

describe Pipewire::SPA::PodFactory::Format do
  it "builds an empty pod" do
    pod = Pipewire::SPA::Pod.format do |f|
    end

    # TODO: Hmm, how to get the format and format enum?
    pod.to_value.should eq(Hash(String, String).new)
  end

  it "sets media type" do
    pod = Pipewire::SPA::Pod.format do |f|
      f.media_type :audio
    end

    pod.to_value.should eq({"mediaType" => "audio"})
  end

  it "sets media subtype" do
    pod = Pipewire::SPA::Pod.format do |f|
      f.media_subtype :raw
    end

    pod.to_value.should eq({"mediaSubtype" => "raw"})
  end

  it "can set both media and subtype in one go" do
    pod = Pipewire::SPA::Pod.format do |f|
      f.media :audio, :raw
    end

    pod.to_value.should eq({"mediaType" => "audio", "mediaSubtype" => "raw"})
  end

  describe "#audio_format" do
    it "sets audio format" do
      pod = Pipewire::SPA::Pod.format do |f|
        f.audio_format :f32
      end

      pod.to_value.should eq({"format" => "F32LE"})
    end

    it "allows setting multiples" do
      pod = Pipewire::SPA::Pod.format do |f|
        f.audio_format :f32, :s16
      end

      pod.to_value.should eq({"format" => {"default" => "F32LE", "enums" => ["F32LE", "S16LE"]}})
    end
  end

  describe "#video_format" do
    it "sets video format" do
      pod = Pipewire::SPA::Pod.format do |f|
        f.video_format :gbr
      end

      pod.to_value.should eq({"format" => "GBR"})
    end

    it "allows setting multiples" do
      pod = Pipewire::SPA::Pod.format do |f|
        f.video_format :gbr, :gbra
      end

      pod.to_value.should eq({"format" => {"default" => "GBR", "enums" => ["GBR", "GBRA"]}})
    end
  end

  describe "#video_size" do
    it "sets video size" do
      pod = Pipewire::SPA::Pod.format do |f|
        f.video_size({320, 240})
      end

      pod.to_value.should eq({"size" => {320, 240}})
    end

    it "allows setting multiples" do
      pod = Pipewire::SPA::Pod.format do |f|
        f.video_size({320, 240}, {1, 1}, {4096, 4096})
      end

      pod.to_value.should eq(
        {
          "size" => {
            "default" => {320, 240},
            "min"     => {1, 1},
            "max"     => {4096, 4096},
          },
        })
    end
  end

  describe "#video_framerate" do
    it "sets video framerate" do
      pod = Pipewire::SPA::Pod.format do |f|
        f.video_framerate({320, 240})
      end

      pod.to_value.should eq({"framerate" => {320, 240}})
    end

    it "allows setting multiples" do
      pod = Pipewire::SPA::Pod.format do |f|
        f.video_framerate({25, 1}, {0, 1}, {1000, 1})
      end

      pod.to_value.should eq(
        {
          "framerate" => {
            "default" => {25, 1},
            "min"     => {0, 1},
            "max"     => {1000, 1},
          },
        })
    end
  end

  describe "#audio_rate" do
    it "sets audio rate" do
      pod = Pipewire::SPA::Pod.format do |f|
        f.audio_rate 48_000
      end

      pod.to_value.should eq({"rate" => 48000})
    end

    it "allows setting multiples" do
      pod = Pipewire::SPA::Pod.format do |f|
        f.audio_rate 48_000, 1, 192_000
      end

      pod.to_value.should eq(
        {
          "rate" => {
            "default" => 48000,
            "min"     => 1,
            "max"     => 192000,
          },
        })
    end
  end

  it "sets audio channels" do
    pod = Pipewire::SPA::Pod.format do |f|
      f.audio_channels 2
    end

    pod.to_value.should eq({"channels" => 2})
  end

  it "builds a complete raw audio format" do
    pod = Pipewire::SPA::Pod.format do |f|
      f.media :audio, :raw
      f.audio_format :f32
      f.audio_rate 48_000
      f.audio_channels 2
    end

    pod.to_value.should eq(
      {
        "mediaType"    => "audio",
        "mediaSubtype" => "raw",
        "format"       => "F32LE",
        "rate"         => 48000,
        "channels"     => 2,
      }
    )
  end

  it "builds a complete raw video format" do
    pod = Pipewire::SPA::Pod.format do |f|
      f.media_type :video
      f.media_subtype :raw
      f.video_format :rgb, :rgba, :rgbx, :bgrx, :yuy2, :i420
      f.video_size({320, 240}, {1, 1}, {4096, 4096})
      f.video_framerate({25, 1}, {0, 1}, {1000, 1})
    end

    pod.to_value.should eq(
      {
        "mediaType"    => "video",
        "mediaSubtype" => "raw",
        "format"       => {
          "default" => "RGB",
          "enums"   => ["RGB", "RGBA", "RGBx", "BGRx", "YUY2", "I420"],
        },
        "size" => {
          "default" => {320, 240},
          "min"     => {1, 1},
          "max"     => {4096, 4096},
        },
        "framerate" => {
          "default" => {25, 1},
          "min"     => {0, 1},
          "max"     => {1000, 1},
        },
      }
    )
  end
end
