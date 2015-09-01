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
    in_source = source_folder |> File.ls! |> Enum.reject(&hidden_file/1)
    in_sandbox = sandbox_folder |> File.ls! |> Enum.reject(&hidden_file/1)
    {checked_out, remaining} = find_checked_out_and_non_checked_out(in_source, in_sandbox)

    case find_first_non_passing_exercise(checked_out) do
      {_weight, next} ->
        {:next, next}
      nil ->
        case remaining do
          [{_weight, next}|_] ->
            {:next, next}
          [] ->
            :workshop_over
        end
    end
  end

  defp hidden_file(file),
    do: String.starts_with?(file, ".")

  defp find_first_non_passing_exercise(exercises) do
    exercises
    |> Stream.drop_while(&(Exercise.passes?(elem(&1, 1))))
    |> Stream.take(1) |> Enum.to_list |> List.first
  end

  @doc """
  Return the exercises that has been checked out and the ones that are waiting in
  the source directory.
  """
  @spec find_checked_out_and_non_checked_out([String.t], [String.t]) :: {[{Integer, String.t}], [{Integer, String.t}]}
  def find_checked_out_and_non_checked_out(source, sandbox_folder) do
    in_source = create_exercise_set(source)

    in_sandbox =
      sandbox_folder
      |> Enum.filter(&(Regex.match?(~r/^\d+_[a-z][\w_]*$/, &1)))
      |> Enum.map(&strip_number_prefix/1)
      |> create_exercise_set
      |> HashSet.intersection(in_source) # skip folders not in source

    checked_out =
      HashSet.intersection(in_source, in_sandbox)
      |> HashSet.to_list
      |> Exercises.get_weights_from_name(source)
      |> Enum.sort

    not_checked_out =
      HashSet.difference(in_source, in_sandbox)
      |> HashSet.to_list
      |> Exercises.get_weights_from_name(source)
      |> Enum.sort

    {checked_out, not_checked_out}
  end

  defp strip_number_prefix(item) when is_binary item do
    [_weight, name] = String.split(item, "_", parts: 2)
    name
  end

  defp create_exercise_set(exercises) when is_list exercises do
    exercises
    |> Enum.filter(&Exercise.valid_name?/1)
    |> Enum.into(HashSet.new)
  end
end
