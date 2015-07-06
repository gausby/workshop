defmodule Mix.Tasks.Workshop.Info do
  use Mix.Task
  alias IO.ANSI.Docs

  def run(argv) do
    {opts, _, _} = OptionParser.parse(argv, switches: [enabled: :boolean])
    path = "./sample"
    metadata = Workshop.info(path)
    Docs.print_heading metadata.workshop[:title], opts
    Docs.print metadata.workshop[:description], opts
    :ok
  end
end
