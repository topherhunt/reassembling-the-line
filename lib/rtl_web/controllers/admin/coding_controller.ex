defmodule RTLWeb.Admin.CodingController do
  use RTLWeb, :controller
  alias RTL.Videos

  def new(conn, %{"video_id" => video_id}) do
    video = Videos.get_video!(video_id)
    changeset = Videos.coding_changeset(%{video_id: video.id})

    render(conn, "new.html",
      video: video,
      changeset: changeset,
      present_tags: [],
      all_tags: Videos.all_tags(),
      most_recent_tags: Videos.most_recent_tags(20)
    )
  end

  def create(conn, %{"coding" => params}) do
    video_id = params["video_id"]
    # Tags is an index-keyed map (or nil)
    tags = Map.values(params["tags"] || %{})
    coder_id = conn.assigns.current_user.id

    case Videos.insert_coding(%{video_id: video_id, tags: tags, coder_id: coder_id}) do
      {:ok, _} ->
        redirect_to_code_next(conn)

      {:error, changeset, invalid_tags} ->
        video = Videos.get_video!(video_id)
        render_error(conn, "new", changeset, video, tags, invalid_tags)
    end
  end

  def edit(conn, %{"id" => coding_id}) do
    coding = Videos.get_coding!(coding_id) |> Videos.get_coding_preloads()
    changeset = Videos.coding_changeset(coding, %{})

    render(conn, "edit.html",
      video: coding.video,
      changeset: changeset,
      present_tags: Videos.summarize_taggings(coding.taggings),
      all_tags: Videos.all_tags(),
      most_recent_tags: Videos.most_recent_tags(20)
    )
  end

  def update(conn, %{"id" => coding_id, "coding" => params}) do
    coding = Videos.get_coding!(coding_id)
    # Tags is an index-keyed map (or nil)
    tags = Map.values(params["tags"] || %{})
    coder_id = conn.assigns.current_user.id

    case Videos.update_coding(%{coding: coding, tags: tags, coder_id: coder_id}) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Updates are saved.")
        |> redirect(to: admin_video_path(conn, :index))

      {:error, changeset, invalid_tags} ->
        video = Videos.get_video!(coding.video_id)
        render_error(conn, "edit", changeset, video, tags, invalid_tags)
    end
  end

  #
  # Helpers
  #

  defp redirect_to_code_next(conn) do
    if video = Videos.next_video_to_code() do
      conn
      |> put_flash(:info, "Updates are saved! Here's another video to code.")
      |> redirect(to: admin_coding_path(conn, :new, video_id: video.id))
    else
      conn
      |> put_flash(:info, "Updates are saved! There are no more videos to code.")
      |> redirect(to: admin_video_path(conn, :index))
    end
  end

  defp render_error(conn, view, changeset, video, tags_params, invalid_tags) do
    conn
    |> put_flash(:error, invalid_tags_message(invalid_tags))
    |> render("#{view}.html",
      video: video,
      changeset: changeset,
      present_tags: summarize_tags_from_params(tags_params),
      all_tags: Videos.all_tags(),
      most_recent_tags: Videos.most_recent_tags(20)
    )
  end

  def invalid_tags_message(invalid_tags) do
    "Error: Tags can only contain letters, numbers, and spaces. " <>
      "These tags are invalid: [#{Enum.join(invalid_tags, ", ")}]"
  end

  def summarize_tags_from_params(tags_params) do
    tags_params
    |> Enum.map(&%{text: &1["text"], starts_at: &1["starts_at"], ends_at: &1["ends_at"]})
  end
end
