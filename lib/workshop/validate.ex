defmodule Workshop.Validate do
  alias Workshop.ValidationResult, as: Result

  def run do
    tests = [
      &should_have_at_least_one_exercise/0,
      &should_have_unique_weights_for_exercises/0,
      &should_have_unique_titles_for_exercises/0
    ]

    for test <- tests, into: %Result{}, do: apply(test, [])
  end

  defp should_have_at_least_one_exercise do
    cond do
      length(Workshop.Exercises.list!) <= 0 ->
        {:error, "The workshop should have at least one exercise"}
      :otherwise ->
        :ok
    end
  end

  defp should_have_unique_weights_for_exercises do
    exercises = Workshop.Exercises.list!
                |> Enum.map(&(String.split(&1, "_", parts: 2)))
                |> Enum.map(fn [weight, _] -> String.to_integer(weight) end)

    cond do
      length(exercises) != length(Enum.uniq(exercises)) ->
        {:error, "Two or more exercises has the same weight, please make the weights unique"}
      :otherwise ->
        :ok
    end
  end

  defp should_have_unique_titles_for_exercises do
    exercises = Workshop.Exercises.list!
                |> Enum.map(&(String.split(&1, "_", parts: 2)))
                |> Enum.map(fn [_, title] -> title end)

    cond do
      length(exercises) != length(Enum.uniq(exercises)) ->
        {:error, "Two or more exercises has the same title, please make the titles unique"}
      :otherwise ->
        :ok
    end
  end
end
