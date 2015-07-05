defmodule Workshop do
  def find_exercise_folders(folder) do
    folder
    |> File.ls!
    |> Enum.filter(&(String.starts_with? &1, "exercise"))
    |> Enum.filter(&(File.dir?(Path.join(folder, &1))))
  end

  def get_description(folder) do
    {:ok, description} = File.read(Path.join(folder, "README.md"))
    description
  end
end
