# Flags etc. for configuring a project's behavior (as opposed to its text & styling,
# which is what CustomBlocks are for).
# - There's no UI for managing these.
defmodule RTL.Projects.ProjectSetting do
  def defaults do
    %{
      # If true, the explore link will appear in the navbar for this project.
      "show_explore_link" => false,

      # Settings we may add later:
      # - auto_code_next (default true)
    }
  end
end
