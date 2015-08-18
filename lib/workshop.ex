defmodule Workshop do
  use Application

  @type workshop_root :: String.t
  @type exercise_folder :: String.t

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
  Same as `locate_root/1` but will use the current working directory as the starting
  point.
  """
  @spec locate_root() :: {:ok, workshop_root}
                       | {:ok, workshop_root, exercise_folder}
                       | {:error, String.t}
  def locate_root do
    File.cwd! |> locate_root
  end

  @doc """
  Attempt to find the workshop root folder by traversing the file system upwards until
  it find a folder which contains a *.workshop*-folder that has an *exercises* folder
  within.

  This allow the user to execute workshop commands from anywhere in the workshop folder
  structure.

  It takes one argument which is the name of the path it should start looking from.

  If the penultimate folder exist as well in the workshop exercises directory it will
  get used as the current exercise in tasks that require a current exercise.
  """
  @spec locate_root(String.t) :: {:ok, workshop_root}
                               | {:ok, workshop_root, exercise_folder}
                               | {:error, String.t}
  def locate_root(folder) when is_binary(folder) do
    do_locate_root folder
  end

  defp do_locate_root(folder, backtrack \\ nil) when is_binary(folder) do
    candidate = Path.join(folder, ".workshop")
    candidate_exercise_folder = Path.join(candidate, "exercises")
    if File.exists?(candidate) and File.exists?(candidate_exercise_folder) do
      if exercise_exists? backtrack, candidate_exercise_folder do
        {:ok, folder, backtrack}
      else
        {:ok, folder}
      end
    else
      parent = Path.dirname(folder)
      unless folder == parent do
        do_locate_root parent, Path.basename(folder)
      else
        {:error, "Folder is not within a workshop"}
      end
    end
  end

  defp exercise_exists?(nil, _), do: false
  defp exercise_exists?(exercise_name, exercise_folder) do
    case Workshop.Exercise.split_weight_and_name(exercise_name) do
      {_weight, name} ->
        Path.wildcard("#{exercise_folder}/*#{name}/exercise.exs")
        # get the name of the dir
        |> Enum.map(&Path.dirname/1) |> Enum.map(&Path.basename/1)
        |> Enum.map(&Workshop.Exercise.split_weight_and_name/1)
        |> Enum.map(&(elem(&1, 1)))
        |> Enum.any?(&(&1 == name))
      _ ->
        false
    end
  end
end
