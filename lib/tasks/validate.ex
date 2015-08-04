defmodule Mix.Tasks.Workshop.Validate do
  use Mix.Task

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {_opts, _, _} = OptionParser.parse(argv, switches: [system: :boolean])

    Workshop.validate
    |> handle_validation_result
  end

  defp handle_validation_result(%Workshop.Validate.Result{errors: []}) do
    Mix.shell.info "Everything seems to be in order"
  end
  defp handle_validation_result(%Workshop.Validate.Result{errors: errors}) do
    Mix.shell.error """
    This does not seem to be a valid workshop. Please fix the following errors:

    #{errors |> Enum.map(&("  * #{&1}")) |> Enum.join("\n")}
    """
    System.at_exit fn _ ->
      exit({:shutdown, 1})
    end
  end
end
