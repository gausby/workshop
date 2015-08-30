defmodule Workshop.Exercises do
  alias Workshop.Exercise

  @doc """
  List the exercises in the current workshop
  """
  @spec list!(String.t) :: [String.t]
  def list!(folder) do
    folder
    |> Path.join("*/exercise.exs")
    |> Path.wildcard
    |> Enum.map(&(Path.rootname(&1, "exercise.exs")))
    |> Enum.map(&Path.basename/1)
  end

  @doc false
  @spec list!() :: [String.t]
  def list! do
    list! Workshop.Session.get(:exercises_folder)
  end

  @doc """
  List the exercises in the current workshop with the weight and the name
  seperated in a tuple.
  """
  @spec list_by_weight!() :: [{Integer, String.t}]
  def list_by_weight! do
    list!
    |> Enum.map(&Exercise.weight_and_name/1)
    |> Enum.sort
  end

  @spec list_by_weight!(String.t) :: [{Integer, String.t}]
  def list_by_weight!(folder) do
    list!(folder)
    |> Enum.map(&Exercise.weight_and_name/1)
    |> Enum.sort
  end

  @doc """
  Will convert `name` to `weight_name` given a list of names and exercises
  """
  @spec get_weights_from_name([String.t], [String.t]) :: [{Integer, String.t}]
  def get_weights_from_name([], _), do: []
  def get_weights_from_name(exercises, exercise_list) do
    weights =
      Enum.map(exercise_list, &Exercise.weight_and_name/1)
      |> Enum.into(%{}, fn {weight, name} -> {name, weight} end)

    Enum.map(exercises, fn exercise ->
      {Map.get(weights, exercise), exercise}
    end)
  end
end
