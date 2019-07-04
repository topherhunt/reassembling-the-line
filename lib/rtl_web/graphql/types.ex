defmodule RTLWeb.Graphql.Types do
  use Absinthe.Schema.Notation
  alias RTLWeb.Graphql.Resolvers

  object :user do
    field :id, :id
    field :full_name, :string
  end

  object :project do
    field :id, :id
    field :name, :string
    field :tags, list_of(:tag), do: resolve &Resolvers.get_tags/3
  end

  object :prompt do
    field :id, :id
    field :sanitized_text, :string, do: resolve &Resolvers.get_prompt_sanitized_text/3
    field :project, :project, do: resolve &Resolvers.get_project/3
  end

  object :video do
    field :id, :id
    field :speaker_name, :string
    field :permission_show_name, :boolean
    field :thumbnail_url, :string, do: resolve &Resolvers.get_video_thumbnail_url/3
    field :recording_url, :string, do: resolve &Resolvers.get_video_recording_url/3
    field :prompt, :prompt, do: resolve &Resolvers.get_prompt/3
    field :coding, :coding, do: resolve &Resolvers.get_coding/3
  end

  object :coding do
    field :id, :id
    field :completed_at, :datetime
    field :coder, :user, do: resolve &Resolvers.get_coder/3
    field :video, :video, do: resolve &Resolvers.get_video/3
    field :taggings, list_of(:tagging), do: resolve &Resolvers.get_taggings/3
  end

  object :tagging do
    field :id, :id
    field :starts_at, :float
    field :ends_at, :float
    field :tag, :tag, do: resolve &Resolvers.get_tag/3
  end

  object :tag do
    field :id, :id
    field :text, :string
    field :color, :string
    field :count_taggings, :integer, do: resolve &Resolvers.get_tag_count_taggings/3
  end
end
