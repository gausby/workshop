defmodule Mix.Tasks.Workshop.Exercises do
  use Mix.Task

  alias Workshop.Info
  alias Workshop.Exercise
  alias Workshop.Exercises
  alias IO.ANSI.Docs

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {opts, _, _} = OptionParser.parse(argv, switches: [enabled: :boolean])

    Docs.print_heading Info.get(Workshop.Meta, :title), opts
    Docs.print "#{list_exercises}", opts
  end

  defp list_exercises do
    current_exercise = Workshop.State.get(:progress)[:cursor]

    Exercises.list!
    |> Enum.with_index
    |> Enum.map(fn {exercise, index} ->
         number = index + 1
         module = Exercise.load(exercise)
         title = Exercise.get(module, :title)

         if Path.basename(exercise) == current_exercise do
           "  #{number}. *#{title} (current)*\n"
         else
           "  #{number}. #{title}\n"
         end
       end)
  end
end
