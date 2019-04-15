# See Code.format_string!/2
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    plug: :*,
    pipe_through: :*,
    get: :*,
    resources: :*,
    field: :*,
    has_one: :*,
    belongs_to: :*,
    log: :*,
    navigate_to: :*
  ]
]
