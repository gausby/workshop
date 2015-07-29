defmodule Mix.Tasks.Workshop.Info do
  use Mix.Task
  import Workshop.Utils, only: [find_workshop_data_folder!: 0]
  alias IO.ANSI.Docs

  def run(argv) do
    {opts, _, _} = OptionParser.parse(argv, switches: [enabled: :boolean])

    File.cd!("sandbox") # for dev

    find_workshop_data_folder!
    |> Path.join("workshop.exs")
    |> Code.require_file

    Docs.print_heading Workshop.Meta.info[:title], opts
    Docs.print Workshop.Meta.info[:description], opts
    :ok
  end
end
