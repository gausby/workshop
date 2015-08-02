defmodule Mix.Tasks.Workshop.Check do
  use Mix.Task

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {opts, _, _} = OptionParser.parse(argv, switches: [system: :boolean])

    current_exercise = Workshop.State.get(:progress)
    if current_exercise do
      current_exercise_folder = Workshop.State.get(:progress)[:cursor]
                                |> Path.expand(Workshop.Session.get(:exercises_folder))

      # todo, run acceptance test
      [{exercise_module, _} | _] = current_exercise_folder |> Path.join("exercise.exs") |> Code.require_file

      IO.inspect exercise_module.__info__(:attributes)
    else
      Mix.shell.info "The workshop has not been started yet"
    end
  end
end
