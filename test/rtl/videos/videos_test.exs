# TODO: Try moving this to a Videos context test
defmodule RTL.VideosTest do
  use RTL.DataCase, async: true
  alias RTL.Videos

  describe "scopes" do
    test "fetching all coded videos having certain tags" do
      prompt = Factory.insert_prompt()
      v1 = add_tagged_video(prompt, [{"abc", 1, 2}])
      v2 = add_tagged_video(prompt, [{"def", 1, 2}])
      v3 = add_tagged_video(prompt, [{"abc", 1, 2}, {"def", 1, 2}])
      v4 = add_tagged_video(prompt, [{"abc", 1, 2}, {"ghi", 1, 2}, {"def", 1, 2}])
      v5 = add_tagged_video(prompt, [])
      v6 = add_tagged_video(prompt, [{"ghi", 1, 2}, {"jkl", 1, 2}, {"def", 1, 2}])

      filter_tags = [%{name: "abc"}, %{name: "def"}]
      videos = Videos.list_videos(coded: true, having_tags: filter_tags)
      video_ids = Enum.map(videos, & &1.id) |> Enum.sort()

      assert v1.id not in video_ids
      assert v2.id not in video_ids
      assert v3.id in video_ids
      assert v4.id in video_ids
      assert v5.id not in video_ids
      assert v6.id not in video_ids
    end
  end

  describe "tag validations" do
    test "name is required" do
      project = Factory.insert_project()

      {:ok, tag1} = Videos.insert_tag(%{project_id: project.id, name: "some name"})
      assert Videos.get_tag_by(id: tag1.id) != nil

      {:error, changeset} = Videos.insert_tag(%{project_id: project.id, name: ""})
      assert Repo.describe_errors(changeset) == "name can't be blank"
    end

    test "duplicate name in same project is rejected" do
      p1 = Factory.insert_project()
      p2 = Factory.insert_project()
      name = "A unique name"

      {:ok, _} = Videos.insert_tag(%{project_id: p1.id, name: name})

      {:error, changeset} = Videos.insert_tag(%{project_id: p1.id, name: name})
      assert Repo.describe_errors(changeset) =~ "has already been taken"

      {:ok, _} = Videos.insert_tag(%{project_id: p2.id, name: name})
    end
  end

  #
  # Helpers
  #

  defp add_tagged_video(prompt, tags) do
    Factory.insert_video(prompt_id: prompt.id, coded_with_tags: tags)
  end
end
