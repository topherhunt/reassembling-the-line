# I was using ExMachina but found these hand-rolled factories simple to set up
# and more transparent vis-a-vis Ecto association handling.
defmodule RTL.Factory do
  alias RTL.Helpers, as: H
  alias RTL.{Accounts, Projects, Videos}

  def insert_user(params \\ %{}) do
    hex = H.random_hex()

    Accounts.insert_user!(%{
      full_name: params[:full_name] || "User #{hex}",
      email: params[:email] || "user_#{hex}@example.com",
      uuid: params[:uuid] || random_uuid()
    })
  end

  def insert_project(params \\ %{}) do
    hex = H.random_hex()

    Projects.insert_project!(%{
      name: params[:name] || "Project #{hex}",
      uuid: params[:uuid] || random_uuid()
    })
  end

  # TODO: These should all be ! bang functions since they raise on errors
  def insert_video(params \\ %{}) do
    hex = H.random_hex()

    Videos.insert_video!(%{
      title: params[:title] || "Video #{hex}",
      recording_filename: params[:recording_filename] || "#{hex}.webm",
      thumbnail_filename: params[:thumbnail_filename] || "#{hex}.jpg"
    })
  end

  def insert_coding(params \\ %{}) do
    # TODO: For this and similar helpers, maybe assert param keys against a whitelist
    # so consumers can't accidentally input invalid keys.
    default_tags = [%{"text" => "tag1"}, %{"text" => "tag2"}]

    {:ok, coding} =
      Videos.insert_coding(%{
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
    Videos.find_or_create_tag(%{text: params[:text] || "tag_#{H.random_hex()}"})
  end

  defp random_uuid(), do: H.random_hex() <> H.random_hex()
end
