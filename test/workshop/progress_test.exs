defmodule Workshop.ProgressTest do
  use ExUnit.Case

  alias Workshop.Progress

  test "finding checked out and non checked out exercises" do
    assert Progress.find_checked_out_and_non_checked_out([], []) == {[], []}
    # source = ["foo", "bar", "baz"]
    # IO.inspect Progress.find_checked_out_and_non_checked_out(source, ["01_foo"])
  end
end
