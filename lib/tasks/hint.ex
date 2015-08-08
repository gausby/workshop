defmodule Mix.Tasks.Workshop.Hint do
  use Mix.Task
  alias IO.ANSI.Docs
  alias Workshop.Info
  alias Workshop.Exercise

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {opts, _, _} = OptionParser.parse(argv, switches: [system: :boolean])

    current_exercise = Workshop.State.get(:progress)[:cursor]
    if current_exercise do
      [{exercise_module,_}|_] = current_exercise
                                |> Path.expand(Workshop.Session.get(:exercises_folder))
                                |> Path.join("exercise.exs")
                                |> Code.require_file

      workshop_title = Info.get(Workshop.Meta, :title)
      exercise_title = Exercise.get(exercise_module, :title)

      Docs.print_heading "#{workshop_title} - #{exercise_title}", opts
      Docs.print Exercise.get(exercise_module, :hint), opts
    else
      Mix.shell.info "The workshop has not been started yet"
    end
  end
end
