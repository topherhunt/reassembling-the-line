defmodule EducateYourWeb.ComponentView do
  use EducateYourWeb, :view

  def render_component(container, component_name, props) do
    id = "component_container_" <> Base.encode16(:crypto.strong_rand_bytes(4))
    render "shared/render_component.html",
      container: container || "div", # could also be tr or tgroup
      id: id,
      component_name: component_name,
      props: props
  end
end
