# I was using ExMachina but found these hand-rolled factories simple to set up
# and more transparent vis-a-vis Ecto association handling.
defmodule RTL.Factory do
  alias RTL.Helpers
  alias RTL.Accounts
  alias RTL.Videos

  def insert_user(params \\ %{}) do
    hex = Helpers.random_hex
    {:ok, user} = Accounts.insert_user(%{
      full_name: params[:full_name] || "User #{hex}",
      email: params[:email] || "user_#{hex}@example.com",
      uuid: params[:uuid] || Helpers.random_hex <> Helpers.random_hex
    })
    user
  end

  def insert_video(params \\ %{}) do
    hex = Helpers.random_hex
    Videos.insert_video!(%{
      title: params[:title] || "Video #{hex}",
      recording_filename: params[:recording_filename] || "#{hex}.webm",
      thumbnail_filename: params[:thumbnail_filename] || "#{hex}.jpg"
    })
  end

  def insert_coding(params \\ %{}) do
    # TODO: For this and similar helpers, maybe assert param keys against a whitelist
    # so consumers can't accidentally input invalid keys.
    default_tags = [%{"text"=>"tag1"}, %{"text"=>"tag2"}]
    {:ok, coding} = Videos.insert_coding(%{
      video_id: params[:video_id] || insert_video().id,
      coder_id: params[:coder_id] || insert_user().id,
      tags: params[:tags] || default_tags
    })
    coding
  end

  def insert_tagging(params \\ %{}) do
    Videos.insert_tagging!(%{
      coding_id: params[:coding_id] || insert_coding().id,
      tag_id: params[:tag_id] || insert_tag().id,
      starts_at: params[:starts_at],
      ends_at: params[:ends_at]
    })
  end

  def insert_tag(params \\ %{}) do
    Videos.find_or_create_tag(%{text: params[:text] || "tag_#{Helpers.random_hex}"})
  end
end
