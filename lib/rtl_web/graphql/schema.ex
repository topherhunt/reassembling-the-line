# Base schema for our GraphQL api.
# See https://hexdocs.pm/absinthe/our-first-query.html
defmodule RTLWeb.Graphql.Schema do
  use Absinthe.Schema
  alias RTLWeb.Graphql.Resolvers

  # Types for datetimes etc.
  import_types Absinthe.Type.Custom
  import_types RTLWeb.Graphql.Types

  query do
    field :coding, :coding do
      arg :id, non_null(:id)
      resolve &Resolvers.get_coding/3
    end
  end

  mutation do
    field :create_tag, type: :tag do
      arg :project_id, non_null(:id)
      arg :text, non_null(:string)
      resolve &Resolvers.create_tag/3
    end

    field :update_tag, type: :tag do
      arg :id, non_null(:id)
      arg :text, non_null(:string)
      arg :color, :string
      resolve &Resolvers.update_tag/3
    end

    field :delete_tag, type: :tag do
      arg :id, non_null(:id)
      resolve &Resolvers.delete_tag/3
    end

    field :create_tagging, type: :tagging do
      arg :coding_id, non_null(:id)
      arg :tag_id, non_null(:id)
      arg :starts_at, non_null(:float)
      arg :ends_at, non_null(:float)
      resolve &Resolvers.create_tagging/3
    end

    field :update_tagging, type: :tagging do
      arg :id, non_null(:id)
      arg :starts_at, non_null(:float)
      arg :ends_at, non_null(:float)
      resolve &Resolvers.update_tagging/3
    end

    field :delete_tagging, type: :tagging do
      arg :id, non_null(:id)
      resolve &Resolvers.delete_tagging/3
    end
  end
end
