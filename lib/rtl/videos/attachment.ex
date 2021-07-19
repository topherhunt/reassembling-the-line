# This module uses the low-level ExAws commands rather than an attachment library like Arc
# because I found Arc to be a leaky abstraction.
defmodule RTL.Videos.Attachment do
  alias RTL.Helpers, as: H

  def upload_file(local_filepath) do
    filename = Path.basename(local_filepath)
    s3_options = [{:acl, "public-read"}]

    local_filepath
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(s3_bucket(), path(filename), s3_options)
    |> ExAws.request!()
    # Old non-streamed logic (less performant):
    # ExAws.S3.put_object(s3_bucket(), s3_path, File.read!(path), s3_options)

    {:ok, url(filename), filename}
  end

  def presigned_upload_url(filename) do
    config = ExAws.Config.new(:s3)
    # This ACL is no longer needed since I set the bucket policy to public-read.
    params = [{"x-amz-acl", "public-read"}, {"contentType", "binary/octet-stream"}]
    opts = [query_params: params]
    {:ok, url} = ExAws.S3.presigned_url(config, :put, s3_bucket(), path(filename), opts)
    url
  end

  def delete_file(filename) do
    ExAws.S3.delete_object(s3_bucket(), path(filename)) |> ExAws.request!()
  end

  def url(filename), do: "https://#{s3_host()}/#{s3_bucket()}/#{path(filename)}"

  def path(filename), do: "#{s3_env()}/interviews/#{filename}"

  #
  # Internal
  #

  # NOTE: S3 is moving to a "virtual host" api format where the bucket is part of the host.
  # ExAws doesn't support virtual hosts yet, so for now we'll stay with the old "path" api.
  # More info: https://docs.aws.amazon.com/AmazonS3/latest/dev/VirtualHosting.html
  defp s3_host, do: H.env!("S3_HOST")
  defp s3_bucket, do: H.env!("S3_BUCKET")
  defp s3_env, do: "#{Mix.env()}"
end
