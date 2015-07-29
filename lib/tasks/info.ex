defmodule Mix.Tasks.Workshop.Info do
  use Mix.Task
  import Workshop.Utils, only: [find_workshop_data_folder: 0]
  alias IO.ANSI.Docs

  def run(argv) do
    {opts, _, _} = OptionParser.parse(argv, switches: [enabled: :boolean])

    File.cd!("sandbox") # for dev
    {:ok, path} = find_workshop_data_folder

    Code.require_file(Path.join(path, "workshop.exs"))
    metadata = Workshop.Meta.info()
    Docs.print_heading metadata[:title], opts
    Docs.print metadata[:description], opts
    :ok
  end
end
