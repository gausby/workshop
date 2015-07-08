defmodule WorkshopTest do
  use ExUnit.Case

  test "listing exercise folders in a workshop" do
    assert Workshop.find_exercise_folders(Path.join(File.cwd!, "sample")) == ["01_the_beginning", "02_the_end"]
  end

  test "get a workshop description" do
    assert Workshop.info("./sample").workshop[:description] == "This workshop is a sample workshop used for developing the workshop.\n"
  end

  test "get a workshop title" do
    assert Workshop.info("./sample").workshop[:title] == "A sample workshop!"
  end

end
