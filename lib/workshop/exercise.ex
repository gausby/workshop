defmodule Workshop.Exercise do
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
end
