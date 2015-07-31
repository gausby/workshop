defmodule Mix.Tasks.Workshop.Exercises do
  use Mix.Task
  import Workshop.Utils, only: [find_workshop_data_folder: 0,
                                find_exercise_folders!: 0,
                                get_exercise_title!: 1,
                                ensure_state: 0]
  alias IO.ANSI.Docs

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    {opts, _, _} = OptionParser.parse(argv, switches: [enabled: :boolean])

    File.cd!("sandbox") # for dev
    ensure_state
    {:ok, path} = find_workshop_data_folder

    current_exercise = Workshop.State.get(:progress)[:cursor]

    Code.require_file(Path.join(path, "workshop.exs"))
    metadata = Workshop.Meta.info
    exercises_folder = Path.join(path, "exercises")

    exercises = list_exercises(find_exercise_folders!, exercises_folder, current_exercise)

    Docs.print_heading metadata[:title], opts
    Docs.print "#{exercises}", opts
    :ok
  end

  def list_exercises(exercises, exercises_folder, current \\ nil) do
    exercises
    |> Enum.map(fn exercise ->
         exercise_title = Path.join(exercises_folder, exercise)
                          |> get_exercise_title!
         {exercise_title, Path.basename(exercise) == current}
       end)
    |> Enum.with_index
    |> Enum.map(fn
         {{item, true}, index} ->
           "  #{(index + 1)}. *#{item} (current)*\n"

         {{item, _}, index} ->
           "  #{(index + 1)}. #{item}\n"
       end)
  end

end
