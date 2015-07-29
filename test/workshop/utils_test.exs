defmodule Workshop.UtilsTest do
  use ExUnit.Case, async: true
  import Workshop.Utils

  test "should be able to locate the workshop root" do
    target = Path.expand("test/fixtures/folders/")

    assert {:ok, ^target} = find_workshop_folder(Path.expand("test/fixtures/folders"))
    assert {:ok, ^target} = find_workshop_folder(Path.expand("test/fixtures/folders/.workshop"))
    assert {:ok, ^target} = find_workshop_folder(Path.expand("test/fixtures/folders/foo/bar"))
    assert {:ok, ^target} = find_workshop_folder(Path.expand("test/fixtures/folders/.workshop/exercises"))
    assert {:error, _reason} = find_workshop_folder(Path.expand("test/fixtures/"))
  end

  test "should be able to locate the workshop data root" do
    target = Path.expand("test/fixtures/folders/.workshop")

    assert {:ok, ^target} = find_workshop_data_folder(Path.expand("test/fixtures/folders"))
    assert {:ok, ^target} = find_workshop_data_folder(Path.expand("test/fixtures/folders/.workshop"))
    assert {:ok, ^target} = find_workshop_data_folder(Path.expand("test/fixtures/folders/foo/bar"))
    assert {:ok, ^target} = find_workshop_data_folder(Path.expand("test/fixtures/folders/.workshop/exercises"))
    assert {:error, _reason} = find_workshop_data_folder(Path.expand("test/fixtures/"))
  end
end
