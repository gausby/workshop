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
      possible_exercise_folder = strip_number_prefix(backtrack)
      if exercise_exists? possible_exercise_folder, candidate_exercise_folder do
        {:ok, folder, possible_exercise_folder}
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
    Path.wildcard("#{exercise_folder}/*#{exercise_name}/exercise.exs")
    |> Enum.map(&Path.dirname/1) |> Enum.map(&Path.basename/1) # get the name of the dir
    |> Enum.any?(&(&1 == exercise_name))
  end

  @valid_exercise_name_with_number_prefix ~r/^\d+_[a-z][\w_]*$/
  def strip_number_prefix(nil), do: nil
  def strip_number_prefix(subject) when is_binary subject do
    if Regex.match?(@valid_exercise_name_with_number_prefix, subject) do
      [_weight, name] = String.split(subject, "_", parts: 2)
      name
    else
      subject
    end
  end
end
