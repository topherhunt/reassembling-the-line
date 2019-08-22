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
    # See https://stackoverflow.com/a/42211543/1729692

    config = ExAws.Config.new(:s3)
    path = "uploads/#{type}/#{filename}"
    params = [{"x-amz-acl", "public-read"}, {"contentType", "binary/octet-stream"}]
    # `virtual_host: true` is required because we're in a non-US S3 region
    opts = [query_params: params]
    {:ok, url} = ExAws.S3.presigned_url(config, :put, s3_bucket(), path, opts)
    url
  end

  def url(type, filename) do
    validate_type(type)
    "https://#{s3_host()}/#{s3_bucket()}/uploads/#{type}/#{filename}"
  end

  #
  # Internal
  #

  # TODO: We don't need separate subfolders for thumbnails vs recordings.
  # Move everything to be in one uploads/ folder.
  defp validate_type(type) do
    unless type in ~w(recording thumbnail), do: raise "Unknown type: #{type}"
  end

  # NOTE: S3 is moving to a "virtual host" api format where the bucket is part of the host.
  # ExAws doesn't support this format yet, so for now we'll stay with the old "path" api.
  # More info: https://docs.aws.amazon.com/AmazonS3/latest/dev/VirtualHosting.html
  defp s3_host do
    Application.fetch_env!(:ex_aws, :s3) |> Keyword.fetch!(:host)
    # "s3-#{H.env!("S3_REGION")}.amazonaws.com"
  end

  defp s3_bucket, do: H.env!("S3_BUCKET")
end
