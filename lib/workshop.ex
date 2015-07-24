defmodule Workshop do
  def find_exercise_folders!(folder) do
    folder
    |> File.ls!
    |> Enum.filter(&(String.match?(&1, ~r/^\d/)))
    |> Enum.filter(&(File.dir?(Path.join(folder, &1))))
  end

  def info(folder) do
    path = Path.join(folder, "workshop.exs")
    Code.load_file(path) |> hd |> elem(0)
  end

  @headline_char ?#
  def get_exercise_title!(exercise_folder) do
    [line, line2] = Path.join(exercise_folder, "README.md")
                    |> File.stream!
                    |> Enum.take(2)
    cond do
      Regex.run(~r/[^=]/, line2 |> String.strip) == nil ->
        String.strip(line)
      line ->
        line |> String.lstrip(@headline_char) |> String.lstrip
    end
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
