# This module uses the low-level ExAws commands rather than an attachment library like Arc
# because I found Arc to be a leaky abstraction.
defmodule RTL.Videos.Attachment do
  alias RTL.Helpers, as: H

  def upload_file(type, local_filepath) do
    validate_type(type)
    filename = Path.basename(local_filepath)
    s3_path = "uploads/#{type}/#{filename}"
    s3_options = [{:acl, "public-read"}]

    local_filepath
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(s3_bucket(), s3_path, s3_options)
    |> ExAws.request!()
    # Old non-streamed logic (less performant):
    # ExAws.S3.put_object(s3_bucket(), s3_path, File.read!(path), s3_options)

    {:ok, url(type, filename), filename}
  end

  def presigned_upload_url(type, filename) do
    validate_type(type)
    config = ExAws.Config.new(:s3)
    path = "uploads/#{type}/#{filename}"
    # This ACL is no longer needed since I set the bucket policy to public-read.
    params = [{"x-amz-acl", "public-read"}, {"contentType", "binary/octet-stream"}]
    opts = [query_params: params]
    {:ok, url} = ExAws.S3.presigned_url(config, :put, s3_bucket(), path, opts)
    url
  end

  def url(type, filename) do
    validate_type(type)
    "https://#{s3_host()}/#{s3_bucket()}/uploads/#{type}/#{filename}"
  end

  def delete_file(type, filename) do
    validate_type(type)
    s3_path = "uploads/#{type}/#{filename}"
    ExAws.S3.delete_object(s3_bucket(), s3_path) |> ExAws.request!()
  end

  #
  # Internal
  #

  # TODO: We don't need separate subfolders for thumbnails vs recordings.
  # Move everything to be in one uploads/ folder.
  defp validate_type(type) do
    unless type in ~w(recording thumbnail test), do: raise "Unknown type: #{type}"
  end

  # NOTE: S3 is moving to a "virtual host" api format where the bucket is part of the host.
  # ExAws doesn't support virtual hosts yet, so for now we'll stay with the old "path" api.
  # More info: https://docs.aws.amazon.com/AmazonS3/latest/dev/VirtualHosting.html
  defp s3_host, do: H.env!("S3_HOST")
  defp s3_bucket, do: H.env!("S3_BUCKET")
end
