defmodule Workshop.Exercise do
  import Mix.Generator

  @doc false
  defmacro __using__(_opts) do
    quote do
      Enum.each [:title, :description, :hint],
        &Module.register_attribute(__MODULE__, &1, persist: true)
    end
  end

  @spec get(atom, atom) :: String.t | nil
  def get(module, subject) when is_atom(module) and is_atom(subject) do
    case List.keyfind module.__info__(:attributes), subject, 0 do
      {^subject, [content|_]} -> content
      _ -> nil
    end
  end

  defdelegate validate(exercise), to: Workshop.Exercise.Validate, as: :run

  @spec load(String.t) :: atom
  def load(folder) do
    loaded = Workshop.Session.get(:exercises, [])
    key = String.to_atom(folder)
    case List.keyfind loaded, key, 0 do
      {^key, exercise_module} ->
        exercise_module
      _ ->
        [{exercise_module,_}|_] = folder
                                  |> Path.expand(Workshop.Session.get(:exercises_folder))
                                  |> Path.join("exercise.exs")
                                  |> Code.require_file

        Workshop.Session.put :exercises, [{key, exercise_module} | loaded]
        exercise_module
    end
  end

  @spec files_folder(String.t) :: String.t
  def files_folder(exercise_folder) do
    Workshop.Session.get(:exercises_folder)
    |> Path.join(exercise_folder)
    |> Path.join("files")
  end

  @spec copy_files_to_sandbox(String.t) :: :ok | {:error, String.t}
  def copy_files_to_sandbox(exercise_folder) do
    destination = Path.expand(exercise_folder, Workshop.Session.get(:folder))
    case create_directory(destination) do
      :ok ->
        files_folder(exercise_folder)
        |> do_copy_files_to_sandbox(destination)
        :ok
      _ ->
        {:error, "Could not create destination folder"}
    end
  end

  defp do_copy_files_to_sandbox(source, destination) do
    source
    |> File.ls!
    |> Enum.each(fn item ->
      if File.dir? item do
        new_destination = Path.join(destination, item)
        create_directory(new_destination)
        do_copy_files_to_sandbox(Path.join(source, item), new_destination)
      else
        content = File.read!(Path.join(source, item))
        create_file(Path.join(destination, item), content)
      end
    end)
  end
end
