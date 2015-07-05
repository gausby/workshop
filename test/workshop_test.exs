defmodule WorkshopTest do
  use ExUnit.Case

  test "listing exercise folders in a workshop" do
    assert Workshop.find_exercise_folders(Path.join(File.cwd!, "sample")) == ["exercise_1", "exercise_2"]
  end

  test "get a workshop description" do
    assert Workshop.get_description(Path.join(File.cwd!, "sample")) == "A sample workshop\n=================\n"
  end
end
