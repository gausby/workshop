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

  @doc """
  Attempt to find the workshop root folder by traversing the file system upwards untill
  it find a folder which contains a *.workshop*-folder that has an *exercises* folder
  within.

  This allow the user to execute workshop commands from anywhere in the workshop folder
  structure.

  It takes one argument which is the name of the path it should start looking from.
  """
  @spec locate_root(String.t) :: {:ok, String.t} | {:error, String.t}
  def locate_root(folder) when is_binary(folder) do
    candidate = Path.join(folder, ".workshop")
    if File.exists?(candidate) and File.exists?(Path.join(candidate, "exercises")) do
      {:ok, folder}
    else
      parent = Path.dirname(folder)
      unless folder == parent do
        locate_root parent
      else
        {:error, "Folder is not within a workshop"}
      end
    end
  end

  @doc """
  Same as `locate_root/1` but will use the current working directory as the starting
  point.
  """
  @spec locate_root() :: {:ok, String.t} | {:error, String.t}
  def locate_root do
    File.cwd! |> locate_root
  end
end
