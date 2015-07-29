defmodule Mix.Tasks.Workshop.Next do
  use Mix.Task
  import Mix.Generator
  import Workshop.Utils, only: [find_exercise_folders!: 1,
                                find_workshop_folder: 0,
                                find_workshop_data_folder: 0]

  def run(_) do
    File.cd("sandbox") # for developent
    path = find_next_exercise
    source = Path.join(path, "files")
    {:ok, workshop_folder} = find_workshop_folder
    destination = Path.join(workshop_folder, Path.basename(path))

    case File.mkdir(destination) do
      :ok ->
        copy_exercise_files_to_sandbox(source, destination)
        Mix.shell.info "Exercise files written to #{destination}"
      {:error, :eexist} ->
        Mix.shell.info "Exercise folder #{destination} already exist"
    end
  end

  defp find_next_exercise do
    {:ok, path} = find_workshop_data_folder
    exercises = Path.join(path, "exercises")
                |> find_exercise_folders!

    [first| _] = exercises

    path
    |> Path.join("exercises")
    |> Path.join(first)
  end

  defp copy_exercise_files_to_sandbox(source, destination) do
    source
    |> File.ls!
    |> Enum.each(fn item ->
      if File.dir? item do
        new_destination = Path.join(destination, item)
        create_directory(new_destination)
        copy_exercise_files_to_sandbox(Path.join(source, item), new_destination)
      else
        content = File.read!(Path.join(source, item))
        create_file(Path.join(destination, item), content)
      end
    end)
  end
end
