defmodule Mix.Tasks.Workshop.Start do
  use Mix.Task
  alias IO.ANSI.Docs
  alias Workshop.Info

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])

    handle_result(cond do
      fail_doctor? ->
        {:error, """
        The system does not yet fit the requirements for this workshop.

        Please run the command:

          `mix workshop.doctor`

        To get a report on what is missing.
        """}
      fail_workshop_validation? ->
        {:error, """
        This does not appear to be a valid workshop. Please run the command:

          `mix workshop.validate`

        This will display the validation results.
        """}
      :otherwise ->
        :ok
    end)
  end

  defp handle_result(:ok) do
    Docs.print_heading Info.get(Workshop.Meta, :title)
    Docs.print Info.get(Workshop.Meta, :introduction)
  end
  defp handle_result({:error, reason}) do
    Mix.shell.error reason
    System.at_exit fn _ ->
      exit({:shutdown, 1})
    end
  end

  # wrappers for validators
  defp fail_doctor? do
    case Workshop.doctor do
      %{runs: x, passed: x} ->
        false
      _ ->
        true
    end
  end

  defp fail_workshop_validation? do
    case Workshop.validate do
      %{runs: x, passed: x} ->
        false
      _ ->
        true
    end
  end
end
