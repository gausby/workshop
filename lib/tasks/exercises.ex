defmodule Mix.Tasks.Workshop.Exercises do
  use Mix.Task
  import Workshop.Utils, only: [find_workshop_data_folder: 0,
                                find_exercise_folders!: 1,
                                get_exercise_title!: 1]
  alias IO.ANSI.Docs

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    {opts, _, _} = OptionParser.parse(argv, switches: [enabled: :boolean])

    File.cd!("sandbox") # for dev
    {:ok, path} = find_workshop_data_folder

    Code.require_file(Path.join(path, "workshop.exs"))
    metadata = Workshop.Meta.info
    exercises_folder = Path.join(path, "exercises")

    exercises = exercises_folder
                |> find_exercise_folders!
                |> Enum.map(&(Path.join(exercises_folder, &1)))
                |> Enum.map(&get_exercise_title!/1)
                |> Enum.with_index
                |> Enum.map(fn {item, index} -> "#{(index + 1)}. #{item}\n" end)

    Docs.print_heading metadata[:title], opts
    Docs.print "#{exercises}", opts
    :ok
  end

end
