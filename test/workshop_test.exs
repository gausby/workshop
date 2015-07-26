defmodule WorkshopTest do
  use ExUnit.Case

  @tag :pending
  test "listing exercise folders in a workshop" do
  end

  @tag :pending
  test "get a workshop description" do
  end

  @tag :pending
  test "get a workshop title" do
  end

  test "should be able to locate the workshop data root" do
    target = Path.expand("test/fixtures/folders/.workshop")

    assert {:ok, ^target} = Workshop.find_workshop_data_folder(Path.expand("test/fixtures/folders"))
    assert {:ok, ^target} = Workshop.find_workshop_data_folder(Path.expand("test/fixtures/folders/.workshop"))
    assert {:ok, ^target} = Workshop.find_workshop_data_folder(Path.expand("test/fixtures/folders/foo/bar"))
    assert {:ok, ^target} = Workshop.find_workshop_data_folder(Path.expand("test/fixtures/folders/.workshop/exercises"))
    assert {:error, _reason} = Workshop.find_workshop_data_folder(Path.expand("test/fixtures/"))
  end

  test "should be able to locate the workshop root" do
    target = Path.expand("test/fixtures/folders/")

    assert {:ok, ^target} = Workshop.find_workshop_folder(Path.expand("test/fixtures/folders"))
    assert {:ok, ^target} = Workshop.find_workshop_folder(Path.expand("test/fixtures/folders/.workshop"))
    assert {:ok, ^target} = Workshop.find_workshop_folder(Path.expand("test/fixtures/folders/foo/bar"))
    assert {:ok, ^target} = Workshop.find_workshop_folder(Path.expand("test/fixtures/folders/.workshop/exercises"))
    assert {:error, _reason} = Workshop.find_workshop_folder(Path.expand("test/fixtures/"))
  end
end
