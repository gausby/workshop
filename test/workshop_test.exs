defmodule WorkshopTest do
  use ExUnit.Case

  test "should be able to locate the workshop root" do
    target = Path.expand("test/fixtures/folders/")

    assert {:ok, ^target} = Workshop.locate_root(Path.expand("test/fixtures/folders"))
    assert {:ok, ^target} = Workshop.locate_root(Path.expand("test/fixtures/folders/.workshop"))
    assert {:ok, ^target} = Workshop.locate_root(Path.expand("test/fixtures/folders/foo/bar"))
    assert {:ok, ^target} = Workshop.locate_root(Path.expand("test/fixtures/folders/.workshop/exercises"))
    assert {:error, _reason} = Workshop.locate_root(Path.expand("test/fixtures/"))
  end

  # ensure that the version number we report in workshop conform with the version statet in the mix file
  test "reported version number should match the version specified in the mix.exs" do
    assert Workshop.Mixfile.project[:version] == Workshop.version
  end
end
