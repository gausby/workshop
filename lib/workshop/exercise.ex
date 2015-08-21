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
      {:hint, content} ->
        content

      {^subject, [content|_]} ->
        content

      _ ->
        nil
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

  @doc """
  Check whether or not the given name is a valid exercise name. A valid exercise
  name shall start with a letter, and must only contain letters, underscores and
  numbers.
  """
  @spec valid_name?(String.t) :: Boolean
  def valid_name?(name) when is_bitstring(name) do
    Regex.match?(~r/^[a-z][\w_]*$/, name) && name == String.downcase(name)
  end

  @doc """
  Check whether or not the given exercise name has been taken by an already
  existing exercise.
  """
  @spec name_taken?(String.t) :: Boolean
  def name_taken?(name) when is_bitstring(name) do
    Workshop.Exercises.list_by_weight!
    |> Enum.any?(&(elem(&1, 1) == name))
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

  @doc """
  Get the short name of a given module
  """
  @spec get_identifier(Atom) :: Atom
  def get_identifier(exercise_module) do
    exercise_module
    |> to_string |> String.split(".")
    |> Enum.reverse |> hd
    |> String.to_atom
  end

  @doc """
  Increment the number of given hints for the given exercise
  """
  @spec increment_hint_counter(Atom) :: nil
  def increment_hint_counter(exercise_module) do
    exercises_state = Workshop.State.get(:exercises, [])
    hints = get(exercise_module, :hint)

    identifier = get_identifier(exercise_module)
    current_exercise_state = exercises_state[identifier] || [{:hint, 0}]
    if current_exercise_state[:hint] < length hints do
      new_state = Keyword.update!(current_exercise_state, :hint, &(&1 + 1))
      Workshop.State.update(:exercises, Keyword.put(exercises_state, identifier, new_state))
      Workshop.State.persist!
    end
  end

  @doc """
  Split the weight and name from a exercise folder name
  """
  @spec split_weight_and_name(String.t) :: {Integer, String.t}
  def split_weight_and_name(exercise_name) do
    case Regex.run(~r/^(\d+)_([\S]+)$/, exercise_name) do
      [_, weight, name] ->
        {String.to_integer(weight), name}
      _ ->
        {:error, "input was not a valid exercise folder name"}
    end
  end
end
