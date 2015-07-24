defmodule Mix.Tasks.Workshop.Next do
  use Mix.Task
  import Mix.Generator

  def run(_) do
    path = find_next_exercise()
    source = Path.join(path, "files")
    destination = Path.basename(path)

    case File.mkdir(destination) do
      :ok ->
        copy_exercise_files_to_sandbox(source, destination)
        Mix.shell.info "Exercise files written to #{destination}"
      {:error, :eexist} ->
        Mix.shell.info "Exercise folder #{destination} already exist"
    end
  end

  defp find_next_exercise do
    path = "sandbox/.workshop/exercises"
    first = Workshop.find_exercise_folders!(path) |> hd
    Path.join(path, first)
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
