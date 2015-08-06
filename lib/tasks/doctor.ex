defmodule Mix.Tasks.Workshop.Doctor do
  use Mix.Task
  alias Workshop.ValidationResult, as: Result

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {_, _, _} = OptionParser.parse(argv, switches: [system: :boolean])

    Workshop.Doctor.run
    |> handle_result
  end

  defp handle_result(%Result{runs: x, passed: x}) do
    Mix.shell.info "The system should be ready for this workshop"
  end
  defp handle_result(%Result{errors: errors}) do
    Mix.shell.error """
    The system does not fit the requirements for this workshop.

    Please fix the following:

    #{errors |> Enum.map(&("  * #{&1}")) |> Enum.join("\n")}
    """
    System.at_exit fn _ ->
      exit({:shutdown, 1})
    end
  end
end
