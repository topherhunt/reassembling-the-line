defmodule XXX.RTLWeb.ComponentView do
  use RTLWeb, :view

  def render_component_XXX(container, component_name, props) do
    id = "component_container_" <> Base.encode16(:crypto.strong_rand_bytes(4))

    render("shared/render_component.html",
      # could also be tr or tgroup
      container: container || "div",
      id: id,
      component_name: component_name,
      props: props
    )
  end
end
