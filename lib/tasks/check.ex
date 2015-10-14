defmodule Mix.Tasks.Workshop.Check do
  use Mix.Task

  alias Workshop.Exercise
  alias Workshop.Session
  alias Workshop.Validator.Result

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {opts, _, _} = OptionParser.parse(argv, switches: [system: :boolean])

    current_exercise = Session.get(:current_exercise)
    if current_exercise do
      exercise_folder = Path.expand(current_exercise, Session.get(:exercises_folder))
      unless opts[:solution] do
        current_exercise
        |> Workshop.Exercise.exercise_sandbox_name
        |> Path.expand(Workshop.Session.get(:folder))
        |> Exercise.check_solution(exercise_folder)
        |> handle_result
      else
        Exercise.solution_folder(current_exercise)
        |> Exercise.check_solution(exercise_folder)
        |> handle_solution_result
      end
    else
      Mix.shell.info "This command should get executed from within an exercise folder"
    end
  end

  # when checking user solution
  defp handle_result(%Result{errors: [], warnings: []}) do
    exercise = Session.get(:current_exercise)

    unless Exercise.get_status(exercise) == :completed do
      # run `exercise completed` callback when transitioning into completed state
      exercise_module = Exercise.load(exercise)
      Exercise.run_callback(exercise_module, :on_exercise_completed)
    end

    Exercise.set_status(exercise, :completed)

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

  # when checking the solution provided with the exercise
  defp handle_solution_result(%Result{errors: [], warnings: []}) do
    Mix.shell.info "Solution seems fine: Zero errors or warnings."
  end
  defp handle_solution_result(%Result{} = result) do
    messages = Enum.map(result.errors, &("Error: #{&1}")) ++ Enum.map(result.warnings, &("Warning: #{&1}"))
    Mix.shell.error """
    The solution for this exercise did not pass the acceptance test for the following reasons:

    #{messages |> Enum.map(&("  * #{&1}")) |> Enum.join("\n")}

    Please fix these issues before releasing the workshop.
    """
    System.at_exit fn _ ->
      exit({:shutdown, 1})
    end
  end
end
