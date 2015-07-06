defmodule Mix.Tasks.Workshop.Check do
  use Mix.Task

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    {opts, _, _} = OptionParser.parse(argv, switches: [system: :boolean])

    # find current exercise and run the acceptance test
  end
end
