defmodule RTLWeb.ExtraHoundHelpers do
  use ExUnit.CaseTemplate
  use Hound.Helpers # See https://github.com/HashNuke/hound for docs

  def assert_selector(strategy, selector, opts \\ %{}) do
    if opts[:count] do
      assert length(find_all_elements(strategy, selector)) == opts[:count]
    else
      assert length(find_all_elements(strategy, selector)) >= 1
    end
  end

  def refute_selector(strategy, selector) do
    assert length(find_all_elements(strategy, selector)) == 0
  end

  def print_page_source() do
    IO.puts "<<<<<<< Page source: >>>>>>"
    IO.puts page_source()
    IO.puts "<<<<<<<<<<<<<<>>>>>>>>>>>>>"
  end
end
