defmodule Mix.Tasks.Workshop.Exercises do
  use Mix.Task
  alias IO.ANSI.Docs

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    {opts, _, _} = OptionParser.parse(argv, switches: [enabled: :boolean])
    path = "sandbox/.workshop/"
    metadata = Workshop.info(path)
    exercises_folder = Path.join(path, "exercises")

    exercises = exercises_folder
    |> Workshop.find_exercise_folders!
    |> Enum.map(&(Path.join(exercises_folder, &1)))
    |> Enum.map(&Workshop.get_exercise_title!/1)
    |> Enum.with_index
    |> Enum.map(fn {item, index} -> "#{(index + 1)}. #{item}\n" end)

    Docs.print_heading metadata.info[:title], opts
    Docs.print "#{exercises}", opts

    :ok
  end

end
