defmodule Mix.Tasks.Workshop.Check do
  use Mix.Task

  alias Workshop.Exercise
  alias Workshop.Session
  alias Workshop.ValidationResult, as: Result

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {_opts, _, _} = OptionParser.parse(argv, switches: [system: :boolean])

    current_exercise = Session.get(:current_exercise)
    if current_exercise do
      exercise_folder = current_exercise |> Path.expand(Session.get(:exercises_folder))
      test_helper = "test/test_helper.exs" |> Path.expand(exercise_folder)

      [{module, _}| _] = Code.require_file(test_helper)

      module.exec(current_exercise)
      |> handle_result
    else
      Mix.shell.info "This command should get executed from within an exercise folder"
    end
  end

  defp handle_result(%Result{errors: [], warnings: []}) do
    Session.get(:current_exercise) |> Exercise.set_status(:completed)

    Mix.shell.info """
    All good! Type `mix workshop.next` to progress to next exercise
    """
  end

  defp handle_result(%Result{} = result) do
    Session.get(:current_exercise) |> Exercise.set_status(:in_progress)

    messages = Enum.map(result.errors, &("Error: #{&1}")) ++ Enum.map(result.warnings, &("Warning: #{&1}"))
    Mix.shell.error """
    The current solution did not pass the acceptance test for the following reasons:

    #{messages |> Enum.map(&("  * #{&1}")) |> Enum.join("\n")}

    Try the `mix workshop.hint` or `mix workshop.help` commands if you are stuck.
    """
    System.at_exit fn _ ->
      exit({:shutdown, 1})
    end
  end
end
