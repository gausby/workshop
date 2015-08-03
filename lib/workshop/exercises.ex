defmodule Workshop.Exercises do
  def list! do
    exercises_folder = Workshop.Session.get(:exercises_folder)

    exercises_folder
    |> File.ls!
    |> Enum.filter(&(String.match?(&1, ~r/^\d/)))
    |> Enum.filter(&(File.dir?(Path.join(exercises_folder, &1))))
  end
end
