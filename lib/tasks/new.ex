defmodule Mix.Tasks.Workshop.New do
  use Mix.Task

  @shortdoc "Create a new workshop or exercise"
  @moduledoc """
  Creates a new workshop or exercise.
  """

  @spec run(OptionParser.argv) :: :ok
  def run(_) do
    Mix.shell.info """
    Please specify if you want to create a new workshop or exercise using

      `mix workshop.new.workshop`

    or

      `mix workshop.new.exercise`
    """
  end
end
