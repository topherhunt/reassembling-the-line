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
    # TODO
  end
end
