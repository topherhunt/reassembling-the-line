# I was using ExMachina but found these hand-rolled factories simple to set up
# and more transparent vis-a-vis Ecto association handling.
defmodule RTL.Factory do
  alias RTL.{Accounts, Projects, Videos}

  def insert_user(params \\ %{}) do
    assert_no_keys_except(params, [:full_name, :email, :uuid])
    uuid = random_uuid()

    Accounts.insert_user!(%{
      full_name: params[:full_name] || "User #{uuid}",
      email: params[:email] || "user_#{uuid}@example.com",
      uuid: params[:uuid] || random_uuid()
    })
  end

  def insert_project(params \\ %{}) do
    assert_no_keys_except(params, [:name, :uuid])

    Projects.insert_project!(%{
      name: params[:name] || "Project #{random_uuid()}",
      uuid: params[:uuid] || random_uuid()
    })
  end

  def insert_prompt(params \\ %{}) do
    assert_no_keys_except(params, [:project_id, :html])

    Projects.insert_prompt!(%{
      project_id: params[:project_id] || insert_project().id,
      html: params[:html] || "Prompt #{random_uuid()}"
    })
  end

  def insert_video(params \\ %{}) do
    assert_no_keys_except(params, [
      :prompt_id,
      :title,
      :recording_filename,
      :thumbnail_filename,
      :coded_with_tags
    ])

    hex = random_uuid()
    prompt_id = params[:prompt_id] || insert_prompt().id

    video = Videos.insert_video!(%{
      prompt_id: prompt_id,
      speaker_name: "Speaker #{hex}",
      permission: "public",
      permission_show_name: true,
      recording_filename: params[:recording_filename] || "#{hex}.webm",
      thumbnail_filename: params[:thumbnail_filename] || "#{hex}.jpg"
    })

    if tags = params[:coded_with_tags] do
      insert_coding(video_id: video.id, tags: tags)
    end

    video
  end

  def insert_coding(params \\ %{}) do
    # :tags should be a list of 3-value tuples: {text, starts_at, ends_at}
    assert_no_keys_except(params, [:video_id, :coder_id, :completed_at, :tags])

    video_id = params[:video_id] || insert_video().id
    project_id = Videos.get_video!(video_id, preload: :prompt).prompt.project_id
    tags = params[:tags] || []

    coding = Videos.insert_coding!(%{
      video_id: video_id,
      coder_id: params[:coder_id] || insert_user().id,
      completed_at: Keyword.get(params, :completed_at, Timex.now())
    })

    # Ensure each tag exists, and load it
    Enum.each(tags, fn({text, starts_at, ends_at}) ->
      tag_params = [project_id: project_id, text: text]
      tag = Videos.get_tag_by(tag_params) || insert_tag(tag_params)
      insert_tagging(%{
        coding_id: coding.id,
        tag_id: tag.id,
        starts_at: starts_at,
        ends_at: ends_at
      })
    end)

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
    assert_no_keys_except(params, [:project_id, :text, :color])
    Videos.insert_tag!(%{
      project_id: params[:project_id],
      text: params[:text] || "tag_#{random_uuid()}",
      color: params[:color] || Videos.Tag.random_color()
    })
  end

  def random_uuid do
    pool = String.codepoints("ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789")
    Enum.map(1..6, fn _ -> Enum.random(pool) end) |> Enum.join()
  end

  #
  # Internal
  #

  defp assert_no_keys_except(params, allowed_keys) do
    keys = Enum.into(params, %{}) |> Map.keys()

    Enum.each(keys, fn key ->
      unless key in allowed_keys do
        raise "Unexpected key #{inspect(key)}."
      end
    end)
  end
end
