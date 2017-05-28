defmodule Zb.Recording do
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  # use Arc.Ecto.Definition

  @versions [:original]

  # All recordings will be publicly accessible (with the right link)
  # See https://github.com/stavro/arc#access-control-permissions
  @acl :public_read

  # To add a thumbnail version:
  # @versions [:original, :thumb]

  # Whitelist file extensions:
  # I'm not validating the record in this case because it's being uploaded
  # independent of the Phoenix server. This Arc module is mostly useful for access.
  # def validate({file, _}) do
  #   ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  # end

  # Define a thumbnail transformation:
  # def transform(:thumb, _) do
  #   {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  # end

  # Override the persisted filenames:
  # def filename(version, _) do
  #   version
  # end

  # Override the storage directory
  def storage_dir(_version, {_file, scope}) do
    s3_path(scope)
  end

  # Publicly accessible helper
  def s3_path(interview) do
    "uploads/interview_recordings/#{interview.id}.webm"
  end

  def s3_url(interview) do
    "https://s3.amazonaws.com/#{System.get_env("S3_BUCKET")}/#{s3_path(interview)}"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: Plug.MIME.path(file.file_name)]
  # end
end
