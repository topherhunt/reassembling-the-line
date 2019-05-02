# I was using ExMachina but found these hand-rolled factories simple to set up
# and more transparent vis-a-vis Ecto association handling.
defmodule RTL.Factory do
  alias RTL.Helpers, as: H
  alias RTL.{Accounts, Projects, Videos}

  def insert_user(params \\ %{}) do
    assert_no_keys_except(params, [:full_name, :email, :uuid])
    hex = H.random_hex()

    Accounts.insert_user!(%{
      full_name: params[:full_name] || "User #{hex}",
      email: params[:email] || "user_#{hex}@example.com",
      uuid: params[:uuid] || random_uuid()
    })
  end

  def insert_project(params \\ %{}) do
    assert_no_keys_except(params, [:name, :uuid])

    Projects.insert_project!(%{
      name: params[:name] || "Project #{H.random_hex()}",
      uuid: params[:uuid] || random_uuid()
    })
  end

  def insert_prompt(params \\ %{}) do
    assert_no_keys_except(params, [:project_id, :html])

    Projects.insert_prompt!(%{
      project_id: params[:project_id] || insert_project().id,
      html: params[:html] || "Prompt #{H.random_hex()}"
    })
  end

  # TODO: These should all be ! bang functions since they raise on errors
  def insert_video(params \\ %{}) do
    assert_no_keys_except(params, [:prompt_id, :title, :recording_filename, :thumbnail_filename])
    hex = H.random_hex()

    Videos.insert_video!(%{
      prompt_id: params[:prompt_id] || insert_prompt().id,
      title: params[:title] || "Video #{hex}",
      recording_filename: params[:recording_filename] || "#{hex}.webm",
      thumbnail_filename: params[:thumbnail_filename] || "#{hex}.jpg"
    })
  end

  def insert_coding(params \\ %{}) do
    tags_params = params[:tags] || [%{"text" => "tag1"}, %{"text" => "tag2"}]

    assert_no_keys_except(params, [:video_id, :coder_id, :tags])
    Enum.each(tags_params, & assert_no_keys_except(&1, ["text", "starts_at", "ends_at"]))

    {:ok, coding} =
      Videos.insert_coding(%{
        video_id: params[:video_id] || insert_video().id,
        coder_id: params[:coder_id] || insert_user().id,
        tags: tags_params
      })

    coding
  end

  def insert_tagging(params \\ %{}) do
    assert_no_keys_except(params, [:coding_id, :tag_id, :starts_at, :ends_at])

    Videos.insert_tagging!(%{
      coding_id: params[:coding_id] || insert_coding().id,
      tag_id: params[:tag_id] || insert_tag().id,
      starts_at: params[:starts_at],
      ends_at: params[:ends_at]
    })
  end

  def insert_tag(params \\ %{}) do
    assert_no_keys_except(params, [:text])
    Videos.find_or_create_tag(%{text: params[:text] || "tag_#{H.random_hex()}"})
  end

  def random_uuid do
    pool = String.codepoints("ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789")
    # 5 base64 chars gives us 600M combinations; that's plenty of entropy
    Enum.map(1..5, fn _ -> Enum.random(pool) end) |> Enum.join()
  end

  #
  # Internal
  #

  defp assert_no_keys_except(params, allowed_keys) do
    keys = Enum.into(params, %{}) |> Map.keys()

    Enum.each(keys, fn(key) ->
      unless key in allowed_keys do
        raise "Unexpected key #{inspect(key)}."
      end
    end)
  end
end
