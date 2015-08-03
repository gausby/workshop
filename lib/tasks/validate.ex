defmodule Mix.Tasks.Workshop.Validate do
  use Mix.Task

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {opts, _, _} = OptionParser.parse(argv, switches: [system: :boolean])

    %{errors: []}
    |> should_at_least_have_one_exercise
    |> should_unique_weights_for_exercises
    |> should_unique_titles_for_exercises
    |> handle_validation_result
  end

  defp handle_validation_result(%{errors: []}) do
    Mix.shell.info "Everything seems to be in order"
  end
  defp handle_validation_result(%{errors: errors}) do
    Mix.shell.error """
    This does not seem to be a valid workshop. Please fix the following errors:

    #{errors |> Enum.map(&("  * #{&1}")) |> Enum.join("\n")}
    """
    System.at_exit fn _ ->
      exit({:shutdown, 1})
    end
  end

  defp should_at_least_have_one_exercise(state) do
    if length(Workshop.Exercises.list!) > 0 do
      state
    else
      %{state|errors: ["Workshop does not appear to have any exercises"|state.errors]}
    end
  end

  # todo
  defp should_unique_weights_for_exercises(state) do
    state
  end

  # todo
  defp should_unique_titles_for_exercises(state) do
    state
  end
end
