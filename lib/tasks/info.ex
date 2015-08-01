defmodule Mix.Tasks.Workshop.Info do
  use Mix.Task
  alias IO.ANSI.Docs

  def run(argv) do
    Workshop.start([], [])
    {opts, _, _} = OptionParser.parse(argv, switches: [enabled: :boolean])

    Docs.print_heading Workshop.Meta.info[:title], opts
    Docs.print Workshop.Meta.info[:description], opts
  end
end
