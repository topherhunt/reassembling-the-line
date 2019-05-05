# See Code.format_string!/2
[
  import_deps: [:ecto, :phoenix],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    render: :*,
    log: :*,
    navigate_to: :*
  ]
]
