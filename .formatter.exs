# See Code.format_string!/2
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    # Router
    plug: :*,
    pipe_through: :*,
    get: :*,
    resources: :*,

    # Controller
    render: :*,

    # Schemas
    field: :*,
    has_one: :*,
    has_many: :*,
    belongs_to: :*,

    # Other
    log: :*,
    info: :*,
    navigate_to: :*
  ]
]
