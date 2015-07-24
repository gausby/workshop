defmodule Mix.Tasks.Workshop.Info do
  use Mix.Task
  alias IO.ANSI.Docs

  def run(argv) do
    {opts, _, _} = OptionParser.parse(argv, switches: [enabled: :boolean])
    path = "./sandbox/.workshop"
    Code.require_file(Path.join(path, "workshop.exs"))
    metadata = Workshop.Meta.info()
    Docs.print_heading metadata[:title], opts
    Docs.print metadata[:description], opts
    :ok
  end
end
