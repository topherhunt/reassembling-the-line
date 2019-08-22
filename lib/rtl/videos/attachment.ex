defmodule RTL.Videos.Attachment do
  alias RTL.Helpers, as: H

  def upload_file(type, local_filepath) do
    validate_type(type)
    filename = Path.basename(local_filepath)
    s3_path = "uploads/#{type}/#{filename}"
    s3_options = [{:acl, "public-read"}]

    local_filepath
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(s3_path_prefix(), s3_path, s3_options)
    |> ExAws.request!()
    # Old non-streamed logic (less performant):
    # ExAws.S3.put_object(s3_path_prefix(), s3_path, File.read!(path), s3_options)

    {:ok, url(type, filename), filename}
  end

  def presigned_upload_url(type, filename) do
    validate_type(type)
    # See https://stackoverflow.com/a/42211543/1729692

    config = ExAws.Config.new(:s3)
    path = "uploads/#{type}/#{filename}"
    params = [{"x-amz-acl", "public-read"}, {"contentType", "binary/octet-stream"}]
    # `virtual_host: true` is required because we're in a non-US S3 region
    opts = [query_params: params, virtual_host: s3_virtual_host?()]
    {:ok, url} = ExAws.S3.presigned_url(config, :put, bucket(), path, opts)
    url
  end

  def url(type, filename) do
    validate_type(type)
    "https://" <> s3_host() <> s3_path_prefix() <> "uploads/#{type}/#{filename}"
  end

  #
  # Internal
  #

  # TODO: We don't need separate subfolders for thumbnails vs recordings.
  # Move everything to be in one uploads/ folder.
  defp validate_type(type) do
    unless type in ~w(recording thumbnail), do: raise "Unknown type: #{type}"
  end

  # S3 is moving to a "virtual host" api format where the bucket is prepended to the domain
  # instead of being in the url path. ExAws doesn't fully support this yet so I've written
  # some shims.
  # More info: https://docs.aws.amazon.com/AmazonS3/latest/dev/VirtualHosting.html
  defp s3_virtual_host?, do: true # H.env!("S3_VIRTUAL_HOST") == "true"

  defp s3_host do
    if s3_virtual_host?(), do: "#{bucket()}.s3.amazonaws.com", else: "s3.amazonaws.com"
  end

  # NOTE: ExAws hasn't caught up with EU buckets' new format (bucket is prepended to the
  # domain rather than part of the path), so instead of passing the bucket as 1st param
  # here, we pass "/" which is nixed out in ExAws.Operation.S3.add_bucket_to_path/1.
  defp s3_path_prefix do
    if s3_virtual_host?(), do: "/", else: "/#{bucket()}/"
  end

  defp bucket, do: H.env!("S3_BUCKET")
end
