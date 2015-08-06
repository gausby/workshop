defmodule Workshop do
  use Application

  def start(_type, _args) do
    if System.get_env("sandbox") do
      # For development purposes. Use any of the workshop commands like this:
      #
      #    $ sandbox=foo mix workshop.info
      #
      # To use the `foo` folder in the current directory as the target workshop.
      System.get_env("sandbox") |> Path.expand |> File.cd!
    end

    Workshop.Supervisor.start_link([])
    # load workshop meta info
    Workshop.Session.get(:data_folder) |> Path.join("workshop.exs") |> Code.require_file
  end

  defdelegate validate, to: Workshop.Validate, as: :run

  defdelegate doctor, to: Workshop.Doctor, as: :run

end
