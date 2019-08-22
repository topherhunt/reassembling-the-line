defmodule RTL.Videos.Attachment do
  alias RTL.Helpers, as: H
  use Arc.Definition

  # Public api defined by Arc:
  # - url({filename, scope})
  # - store({file_path, scope})

  def presigned_upload_url(path) do
    # See https://stackoverflow.com/a/42211543/1729692
    # `virtual_host: true` is required because we're in a non-US S3 region
    bucket = RTL.Helpers.env!("S3_BUCKET")
    config = ExAws.Config.new(:s3)
    params = [{"x-amz-acl", "public-read"}, {"contentType", "binary/octet-stream"}]
    opts = [query_params: params, virtual_host: true]
    {:ok, url} = ExAws.S3.presigned_url(config, :put, bucket, path, opts)
    url
  end

  #
  # Internals
  #

  # Include ecto support (requires package arc_ecto installed):
  # use Arc.Ecto.Definition

  @versions [:original]
  @acl :public_read

  # To add a thumbnail version:
  # @versions [:original, :thumb]

  # Whitelist file extensions:
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

  # Override the storage directory:
  def storage_dir(_version, {_file, scope}) do
    # TODO: What's this "text" scope for? Can I get rid of it?
    H.assert_list_contains(["recording", "thumbnail", "text"], scope)
    "uploads/#{scope}"
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
