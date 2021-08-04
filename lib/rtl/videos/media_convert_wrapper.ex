# Logic for AWS MediaConvert API which we use to convert videos to standard .mp4 format.
#
# Tips:
# - Basic usage: https://docs.aws.amazon.com/mediaconvert/latest/ug/getting-started.html
# - API: https://docs.aws.amazon.com/mediaconvert/latest/apireference/getting-started.html
# - Setting up IAM role: https://docs.aws.amazon.com/mediaconvert/latest/ug/iam-role.html
# - You can find the mediaconvert API endpoint on the web console.
#
defmodule RTL.Videos.MediaConvertWrapper do
  alias RTL.Helpers, as: H

  def create_job(path, filename) do
    ExAws.MediaConvert.create_job(job_spec(path, filename))
  end

  def list_jobs do
    ExAws.MediaConvert.list_jobs()
  end

  def job_spec(path, filename) do
    bucket = H.env!("S3_BUCKET")
    %{
      "AccelerationSettings" => %{"Mode" => "DISABLED"},
      "Priority" => 0,
      "Queue" => "arn:aws:mediaconvert:eu-central-1:064564039229:queues/Default",
      "Role" => "arn:aws:iam::064564039229:role/service-role/MediaConvert_Default_Role",
      "Settings" => %{
        "Inputs" => [
          %{
            "AudioSelectors" => %{
              "Audio Selector 1" => %{"DefaultSelection" => "DEFAULT"}
            },
            "FileInput" => "https://s3-eu-central-1.amazonaws.com/#{bucket}#{path}/#{filename}",
            "TimecodeSource" => "ZEROBASED",
            "VideoSelector" => %{}
          }
        ],
        "OutputGroups" => [
          %{
            "Name" => "File Group",
            "OutputGroupSettings" => %{
              "FileGroupSettings" => %{
                "Destination" => "s3://#{bucket}#{path}/"
              },
              "Type" => "FILE_GROUP_SETTINGS"
            },
            "Outputs" => [
              %{
                "AudioDescriptions" => [
                  %{
                    "AudioSourceName" => "Audio Selector 1",
                    "CodecSettings" => %{
                      "AacSettings" => %{
                        "Bitrate" => 96000,
                        "CodingMode" => "CODING_MODE_2_0",
                        "SampleRate" => 48000
                      },
                      "Codec" => "AAC"
                    }
                  }
                ],
                "ContainerSettings" => %{"Container" => "MP4", "Mp4Settings" => %{}},
                "VideoDescription" => %{
                  "CodecSettings" => %{
                    "Codec" => "H_264",
                    "H264Settings" => %{
                      "MaxBitrate" => 3000000,
                      "RateControlMode" => "QVBR",
                      "SceneChangeDetect" => "TRANSITION_DETECTION"
                    }
                  }
                }
              }
            ]
          }
        ],
        "TimecodeConfig" => %{"Source" => "ZEROBASED"}
      },
      "StatusUpdateInterval" => "SECONDS_60"
    }
  end
end
