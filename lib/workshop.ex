defmodule Workshop do
  use Application

  def start(_type, _args) do
    File.cd! Path.expand("sandbox") # for development purposes

    Workshop.Supervisor.start_link([])
    # load workshop meta info
    Workshop.Session.get(:data_folder) |> Path.join("workshop.exs") |> Code.require_file
  end
end
