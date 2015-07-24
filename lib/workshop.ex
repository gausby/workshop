defmodule Workshop do
  def find_exercise_folders!(folder) do
    folder
    |> File.ls!
    |> Enum.filter(&(String.match?(&1, ~r/^\d/)))
    |> Enum.filter(&(File.dir?(Path.join(folder, &1))))
  end

  @headline_char ?#
  def get_exercise_title!(exercise_folder) do
    Path.join(exercise_folder, "README.md")
    |> File.stream!
    |> Enum.take(1)
    |> hd
    |> String.lstrip(@headline_char)
    |> String.strip
  end

  # workshops should get prefixed with a weight
  def get_exercises_by_weight! do
    File.ls!(File.cwd!)
    |> Enum.reject(&(String.starts_with?(&1, ".")))
    |> Enum.map(fn item ->
                  [number, name] = String.split(item, "_", parts: 2)
                  {String.to_integer(number), name}
               end)
    |> Enum.sort
  end
end
