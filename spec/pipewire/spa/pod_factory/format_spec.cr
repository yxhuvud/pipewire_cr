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

  it "sets audio format" do
    pod = Pipewire::SPA::Pod.format do |f|
      f.audio_format :f32
    end

    pod.to_value.should eq({"format" => "F32LE"})
  end

  it "sets audio rate" do
    pod = Pipewire::SPA::Pod.format do |f|
      f.audio_rate 48_000
    end

    pod.to_value.should eq({"rate" => 48000})
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
end
