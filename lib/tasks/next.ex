defmodule Mix.Tasks.Workshop.Next do
  use Mix.Task
  import Mix.Generator
  import Workshop.Utils, only: [find_exercise_folders!: 0]

  def run(_) do
    Workshop.start([], [])

    case find_next_exercise do
      :workshop_over ->
        Mix.shell.info "show workshop debriefing message!"

      {:next, exercise} ->
        source = Workshop.Session.get(:exercises_folder)
                 |> Path.join(exercise)
                 |> Path.join("files")

        destination = Workshop.Session.get(:folder)
                      |> Path.join(exercise)

        result_message = case File.mkdir(destination) do
          :ok ->
            copy_exercise_files_to_sandbox(source, destination)
            "Exercise files written to #{destination}"
          {:error, :eexist} ->
            "Exercise folder #{destination} already exist"
        end

        Workshop.State.update(:progress, cursor: exercise)
        Workshop.State.persist!
        Mix.shell.info result_message
    end
  end

  defp find_next_exercise do
    exercises = find_exercise_folders!
    case Workshop.State.get(:progress)[:cursor] do
      nil ->
        {:next, List.first(exercises)}
      cursor ->
        {_, remaining} = Enum.split_while(exercises, &(cursor != &1))
        case remaining do
          [_current | []] ->
            :workshop_over
          [_current, next|_] ->
            {:next, next}
        end
    end
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
