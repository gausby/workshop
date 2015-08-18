defmodule Workshop.Exercises do
  alias Workshop.Exercise

  @doc """
  List the exercises in the current workshop
  """
  @spec list!() :: [String.t]
  def list! do
    Workshop.Session.get(:exercises_folder)
    |> Path.join("*/exercise.exs")
    |> Path.wildcard
    |> Enum.map(&(Path.rootname(&1, "exercise.exs")))
    |> Enum.map(&Path.basename/1)
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
end
