defmodule Mix.Tasks.Workshop.Info do
  use Mix.Task
  alias IO.ANSI.Docs

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {opts, _, _} = OptionParser.parse(argv, switches: [enabled: :boolean])

    workshop_title = Workshop.Meta.info[:title]
    current_exercise = Workshop.State.get(:progress)[:cursor]

    if current_exercise do
      [{exercise_module,_}|_] = current_exercise
                                |> Path.expand(Workshop.Session.get(:exercises_folder))
                                |> Path.join("exercise.exs")
                                |> Code.require_file

      exercise_title = Workshop.Exercise.get(exercise_module, :title)

      Docs.print_heading "#{workshop_title} - #{exercise_title}", opts
      Docs.print Workshop.Exercise.get(exercise_module, :description), opts
    else
      Docs.print_heading workshop_title, opts
      Docs.print Workshop.Meta.info[:description], opts
    end
  end
end
