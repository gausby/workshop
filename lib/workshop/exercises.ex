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
    |> Enum.map(&Exercise.split_weight_and_name/1)
    |> Enum.sort
  end

  @spec list_by_weight!(String.t) :: [{Integer, String.t}]
  def list_by_weight!(folder) do
    list!(folder)
    |> Enum.map(&Exercise.split_weight_and_name/1)
    |> Enum.sort
  end

  @doc """
  Find the exercise succeeding the current exercise.
  """
  @spec find_next!() :: {:next, String.t} | :workshop_over
  def find_next! do
    exercises = list!
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

  @doc """
  Will convert `name` to `weight_name` given a list of names and exercises
  """
  @spec get_weights_from_name([String.t], [String.t]) :: {Integer, String.t}
  def get_weights_from_name(exercises, exercise_list) do
    weights = Enum.map(exercise_list, &Exercise.split_weight_and_name/1)
              |> Enum.into(%{}, fn {weight, name} -> {name, weight} end)

    Enum.map(exercises, fn exercise ->
      {Map.get(weights, exercise), exercise}
    end)
  end
end
