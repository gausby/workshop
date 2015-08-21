defmodule Workshop.Progress do
  alias Workshop.Exercise
  alias Workshop.Exercises

  @doc """
  Will find the next exercise by looking for the first non passing exercise
  that has already been checked out. If all checked out exercises passes it
  will return the first exercise of the remaining, and return `:workshop_over`
  if there are no more exercises remaining.
  """
  @spec find_next(String.t, String.t) :: {:next, String.t} | :workshop_over
  def find_next(source_folder, sandbox_folder) do
    in_source = source_folder |> File.ls!
    in_sandbox = sandbox_folder |> File.ls!
    {checked_out, remaining} = find_checked_out_and_non_checked_out(in_source, in_sandbox)

    name_map = create_name_map Exercises.list!
    case find_first_non_passing_exercise(checked_out) do
      {_weight, next} ->
        {:next, name_map[next]}
      nil ->
        case remaining do
          [{_weight, next}|_] ->
            {:next, name_map[next]}
          [] ->
            :workshop_over
        end
    end
  end

  defp find_first_non_passing_exercise(exercises) do
    name_map = create_name_map(Exercises.list!)
    exercises
    |> Stream.drop_while(&(Exercise.passes?(name_map[elem(&1, 1)])))
    |> Stream.take(1) |> Enum.to_list |> List.first
  end

  @doc """
  Return the exercises that has been checked out and the ones that are waiting in
  the source directory.
  """
  @spec find_checked_out_and_non_checked_out([String.t], [String.t]) :: {[{Integer, String.t}], [{Integer, String.t}]}
  def find_checked_out_and_non_checked_out(source, sandbox_folder) do
    in_source = create_exercise_set(source)
    in_sandbox = create_exercise_set(sandbox_folder)
                 |> HashSet.intersection(in_source) # skip folders not in source

    not_checked_out = HashSet.difference(in_source, in_sandbox)
                      |> HashSet.to_list
                      |> Exercises.get_weights_from_name(source)
                      |> Enum.sort
    checked_out = HashSet.intersection(in_source, in_sandbox)
                  |> HashSet.to_list
                  |> Exercises.get_weights_from_name(source)
                  |> Enum.sort

    {checked_out, not_checked_out}
  end

  defp create_exercise_set(exercises) when is_list exercises do
    exercises
    |> Enum.map(&Exercise.split_weight_and_name/1)
    |> Enum.reject(&(elem(&1, 0) == :error))
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.into(HashSet.new)
  end

  def create_name_map(exercises) do
    exercises |> Enum.into(%{}, fn weight_and_name ->
      {_weight, name} = Exercise.split_weight_and_name(weight_and_name)
      {name, weight_and_name}
    end)
  end
end
