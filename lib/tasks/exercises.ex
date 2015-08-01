defmodule Mix.Tasks.Workshop.Exercises do
  use Mix.Task
  import Workshop.Utils, only: [find_exercise_folders!: 0, get_exercise_title!: 1]
  alias IO.ANSI.Docs

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {opts, _, _} = OptionParser.parse(argv, switches: [enabled: :boolean])

    Docs.print_heading Workshop.Meta.info[:title], opts
    Docs.print "#{list_exercises}", opts
  end

  def list_exercises do
    exercises_folder = Workshop.Session.get(:exercises_folder)
    current_exercise = Workshop.State.get(:progress)[:cursor]

    find_exercise_folders!
    |> Enum.map(fn exercise ->
         exercise_title = exercises_folder
                          |> Path.join(exercise)
                          |> get_exercise_title!
         {exercise_title, Path.basename(exercise) == current_exercise}
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
