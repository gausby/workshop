defmodule Workshop.ProgressTest do
  use ExUnit.Case

  alias Workshop.Progress

  test "finding checked out and non checked out exercises" do
    assert Progress.find_checked_out_and_non_checked_out([], []) == {[], []}
    source = ["010_foo", "020_bar", "030_baz"]
    # one checked out exercise
    assert Progress.find_checked_out_and_non_checked_out(source, ["1_foo"]) == {
      [{10, "foo"}],
      [{20, "bar"}, {30, "baz"}]
    }
    # sandbox has a unbeknownst to the source
    assert Progress.find_checked_out_and_non_checked_out(source, ["040_quun"]) == {
      [], [{10, "foo"}, {20, "bar"}, {30, "baz"}]
    }
    # everything is checked out:
    assert Progress.find_checked_out_and_non_checked_out(source, source) == {
      [{10, "foo"}, {20, "bar"}, {30, "baz"}], []
    }
  end
end
