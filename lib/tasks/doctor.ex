defmodule Mix.Tasks.Workshop.Doctor do
  use Mix.Task
  alias Workshop.Validator.Result

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {opts, _, _} = OptionParser.parse(argv, switches: [system: :boolean])

    Workshop.Doctor.run
    |> handle_result(opts)
  end

  defp handle_result(%Result{runs: x, passed: x, warnings: []}, _opts) do
    Mix.shell.info "The system should be ready for this workshop"
  end
  defp handle_result(%Result{runs: x, passed: x, warnings: warnings}, opts) do
    message = if opts[:verbose] do
      """
      The system should be ready for this workshop but had the following warnings:

      #{warnings |> Enum.map(&("  * #{&1}")) |> Enum.join("\n")}
      """
    else
      "The system should be ready for this workshop"
    end
    Mix.shell.info message
  end
  defp handle_result(%Result{errors: errors}, _opts) do
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
