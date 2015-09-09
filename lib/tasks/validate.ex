defmodule Mix.Tasks.Workshop.Validate do
  use Mix.Task
  alias Workshop.Validator.Result

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {_opts, _, _} = OptionParser.parse(argv, switches: [system: :boolean])

    Workshop.validate
    |> handle_validation_result
  end

  defp handle_validation_result(%Result{runs: x, passed: x, warnings: []}) do
    Mix.shell.info "#{x}/#{x} passed with zero warnings"
  end
  defp handle_validation_result(%Result{runs: x, passed: x, warnings: warnings}) do
    Mix.shell.info """
    #{x}/#{x} passed but some with warnings:

    #{warnings |> Enum.map(&("  * #{&1}")) |> Enum.join("\n")}
    """
  end
  defp handle_validation_result(%Result{} = result) do
    messages = Enum.map(result.errors, &("Error: #{&1}")) ++ Enum.map(result.warnings, &("Warning: #{&1}"))
    Mix.shell.error """
    #{result.passed}/#{result.runs} passed. Please fix the following issues:

    #{messages |> Enum.map(&("  * #{&1}")) |> Enum.join("\n")}
    """
    System.at_exit fn _ ->
      exit({:shutdown, 1})
    end
  end
end
