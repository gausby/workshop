defmodule Workshop.Exercise do
  import Mix.Generator

  alias Workshop.State
  alias Workshop.Validator.Result

  @doc false
  defmacro __using__(_opts) do
    quote do
      Enum.each [:title, :weight, :description, :task, :hint],
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
        [{exercise_module,_}|_] =
          folder
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

  @doc """
  Get the location of the exercise files folder for a given exercise.

  These are the files that a copied into the exercise sandbox when the user
  progress to the given exercise.
  """
  @spec files_folder(String.t) :: String.t
  def files_folder(exercise_folder) do
    files_folder(exercise_folder, Workshop.Session.get(:exercises_folder))
  end

  @spec files_folder(String.t, String.t) :: String.t
  def files_folder(exercise_folder, folder) do
    folder
    |> Path.join(exercise_folder)
    |> Path.join("files")
  end

  @doc """
  Get the location of the solution folder for a given exercise.
  """
  @spec solution_folder(String.t) :: String.t
  def solution_folder(exercise_folder) do
    solution_folder(exercise_folder, Workshop.Session.get(:exercises_folder))
  end

  @spec solution_folder(String.t, String.t) :: String.t
  def solution_folder(exercise_folder, folder) do
    folder
    |> Path.join(exercise_folder)
    |> Path.join("solution")
  end

  @doc """
  Get the sandbox name of the given exercise.
  """
  @spec exercise_sandbox_name(String.t, [{Integer, String.t}]) :: String.t
  def exercise_sandbox_name(needle, exercises) do
    # we need to know how much padding the prefix number should have, we
    # determine this by looking at the length of the number of exercises
    # represented as a string.
    len = Integer.to_string(length exercises) |> String.length
    len = if len <= 1, do: 2, else: len

    exercise_index = exercises |> Enum.find_index(fn {_, exercise} -> exercise == needle end)

    "#{String.rjust(to_string(exercise_index + 1), len, ?0)}_#{needle}"
  end

  @doc """
  Get the sandbox name of the given exercise. Use the contents of the source
  exercise folder to determine the given weight.
  """
  @spec exercise_sandbox_name(String.t) :: String.t
  def exercise_sandbox_name(exercise) do
    exercise_sandbox_name(exercise, Workshop.Exercises.list_by_weight!)
  end

  @spec copy_files_to_sandbox(String.t) :: :ok | {:error, String.t}
  def copy_files_to_sandbox(exercise_folder) do
    destination =
      exercise_sandbox_name(exercise_folder)
      |> Path.expand(Workshop.Session.get(:folder))

    unless File.exists? destination do
      case create_directory(destination) do
        :ok ->
          source = files_folder(exercise_folder)
          do_copy_files_to_sandbox(source, destination)

          exercises_state = State.get(:exercises, [])
          identifier = load(exercise_folder) |> get_identifier
          current_exercise_state = exercises_state[identifier] || []
          new_state = Keyword.put(current_exercise_state, :status, :in_progress)

          State.update(:exercises, Keyword.put(exercises_state, identifier, new_state))
          State.persist!
          :ok
        _ ->
          {:error, "Could not create destination folder"}
      end
    else
      {:exists, destination}
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
    exercises_state = State.get(:exercises, [])
    hints = get(exercise_module, :hint)

    identifier = get_identifier(exercise_module)
    current_exercise_state = exercises_state[identifier]

    unless Keyword.has_key?(current_exercise_state, :hint) do
      current_exercise_state = Keyword.put(current_exercise_state, :hint, 0)
    end

    if current_exercise_state[:hint] < length hints do
      new_state = Keyword.update!(current_exercise_state, :hint, &(&1 + 1))
      State.update(:exercises, Keyword.put(exercises_state, identifier, new_state))
      State.persist!
    end
  end

  @doc """
  Get the weight and name from an exercise folder name
  """
  @spec weight_and_name(String.t) :: {Integer, String.t}
  def weight_and_name(exercise_name) do
    weight = load(exercise_name) |> get(:weight)
    {weight, exercise_name}
  end

  @doc """
  Look in the exercise state if the exercise has been marked as completed;
  if the exercise has no status at all the solution check will get run and
  the state will get updated.
  """
  @spec passes?(String.t) :: boolean
  def passes?(exercise) do
    identifier = load(exercise) |> get_identifier
    unless Keyword.has_key?(exercises_state, identifier) do
      sandbox_name = exercise_sandbox_name(exercise)
      exercise_folder = Path.expand(exercise, Workshop.Session.get(:exercises_folder))
      set_status(exercise, check_solution(sandbox_name, exercise_folder) |> map_result)
    end

    Keyword.get(exercises_state[identifier], :status, nil) == :completed
  end

  defp exercises_state,
    do: State.get(:exercises, [])

  defp map_result(%Result{runs: x, passed: x}),
    do: :completed
  defp map_result(_),
    do: :in_progress

  @doc """
  Check the user solution against the solution verification script
  """
  @spec check_solution(String.t, String.t) :: Result.t
  def check_solution(solution, exercise_folder) do
    test_helper = "test/test_helper.exs" |> Path.expand(exercise_folder)
    [{module, _}| _] = Code.require_file(test_helper)
    module.exec(solution)
  end

  @doc """
  Get the status of the given exercise
  """
  @spec get_status(String.t) :: :in_progress | :completed | nil
  def get_status(exercise) do
    identifier = load(exercise) |> get_identifier
    exercises_state = State.get(:exercises, [])
    current_exercise_state = exercises_state[identifier] || []
    current_exercise_state[:status]
  end

  @doc """
  Update the status of the given exercise with new status.
  """
  @spec set_status(String.t, Atom) :: :ok
  def set_status(exercise, new_status) do
    identifier = load(exercise) |> get_identifier
    exercises_state = State.get(:exercises, [])
    current_exercise_state = exercises_state[identifier] || []
    new_state = Keyword.put(current_exercise_state, :status, new_status)

    State.update(:exercises, Keyword.put(exercises_state, identifier, new_state))
    State.persist!
  end

  @doc """
  Helper for running callbacks at certain points in the exercise work flow.

  The function expect a exercise module, the function which should get called, defined
  as a public function on the exercise module, and the arguments that the function
  should get called with.

  It will figure the arity of the callback function from the size of the args list.
  """
  @spec run_callback(Atom, Atom, [Any]) :: Any
  def run_callback(exercise_module, callback, args \\ []) do
    if Code.ensure_loaded?(exercise_module) and function_exported?(exercise_module, callback, length args) do
      apply(exercise_module, callback, args)
    end
  end
end
