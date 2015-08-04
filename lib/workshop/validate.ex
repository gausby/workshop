defmodule Workshop.Validate do
  defmodule Result do
    defstruct errors: []
  end

  def run do
    %Result{}
    |> should_at_least_have_one_exercise
    |> should_have_unique_weights_for_exercises
    |> should_have_unique_titles_for_exercises
  end

  # helper function for altering the result state
  defp add_error(state, message) when is_nil(message), do: state
  defp add_error(state, message) when is_bitstring(message) do
    %Result{state|errors: [message|state.errors]}
  end

  defp should_at_least_have_one_exercise(result) do
    add_error(result, unless length(Workshop.Exercises.list!) > 0 do
      "The workshop should have at least one exercise"
    end)
  end

  defp should_have_unique_weights_for_exercises(result) do
    exercises = Workshop.Exercises.list!
                |> Enum.map(&(String.split(&1, "_", parts: 2)))
                |> Enum.map(fn [weight, _] -> String.to_integer(weight) end)

    add_error(result, unless length(exercises) == length(Enum.uniq(exercises)) do
      "Two or more exercises has the same weight, please make the weights unique"
    end)
  end

  defp should_have_unique_titles_for_exercises(result) do
    exercises = Workshop.Exercises.list!
                |> Enum.map(&(String.split(&1, "_", parts: 2)))
                |> Enum.map(fn [_, title] -> title end)

    add_error(result, unless length(exercises) == length(Enum.uniq(exercises)) do
      "Two or more exercises has the same title, please make the titles unique"
    end)
  end
end
