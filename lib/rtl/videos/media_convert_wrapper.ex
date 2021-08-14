# Logic for AWS MediaConvert API which we use to convert videos to standard .mp4 format.
#
# Tips:
# - Basic usage: https://docs.aws.amazon.com/mediaconvert/latest/ug/getting-started.html
# - API: https://docs.aws.amazon.com/mediaconvert/latest/apireference/getting-started.html
# - Setting up IAM role: https://docs.aws.amazon.com/mediaconvert/latest/ug/iam-role.html
# - You can find the mediaconvert API endpoint on the web console.
# - Generating video poster image: https://aws.amazon.com/blogs/media/create-a-poster-frame-and-thumbnail-images-for-videos-using-aws-elemental-mediaconvert/
#
defmodule RTL.Videos.MediaConvertWrapper do
  require Logger
  alias RTL.Helpers, as: H

  # `path` should include the filename (as returned by Videos.Attachment.path())
  # Converting the video might take a minute.
  def create_job(webm_path) do
    unless Mix.env() == :test do
      response = ExAws.MediaConvert.create_job(job_spec(webm_path)) |> ExAws.request!()
      job = response["job"]
      log :info, "Job #{job["id"]} #{job["status"]} (file: #{webm_path})"

      # The return value specifies the filenames of the created resources.
      %{
        mp4: webm_path |> Path.basename() |> String.replace(".webm", ".mp4"),
        jpg: webm_path |> Path.basename() |> String.replace(".webm", ".0000000.jpg")
      }
    end
  end

  def list_jobs do
    ExAws.MediaConvert.list_jobs()
  end

  def job_spec(webm_path) do
    bare_path = Path.dirname(webm_path)
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
            "FileInput" => "https://s3-eu-central-1.amazonaws.com/#{bucket}/#{webm_path}",
            "TimecodeSource" => "ZEROBASED",
            "VideoSelector" => %{}
          }
        ],
        "OutputGroups" => [
          %{
            "Name" => "File Group",
            "OutputGroupSettings" => %{
              "Type" => "FILE_GROUP_SETTINGS",
              "FileGroupSettings" => %{"Destination" => "s3://#{bucket}/#{bare_path}/"}
            },
            "Outputs" => [
              # Output 1: .mp4 file
              %{
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
                },
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
                ]
              },
              # Output 2: a .jpg poster image
              %{
                "ContainerSettings" => %{"Container" => "RAW"},
                "VideoDescription" => %{
                  "CodecSettings" => %{
                    "Codec" => "FRAME_CAPTURE",
                    "FrameCaptureSettings" => %{"MaxCaptures" => 1}
                  }
                }
              }
            ]
          },

        ],
        "TimecodeConfig" => %{"Source" => "ZEROBASED"}
      },
      "StatusUpdateInterval" => "SECONDS_60"
    }
  end

  defp log(level, message), do: Logger.log(level, "MediaConvertWrapper: #{message}")
end
