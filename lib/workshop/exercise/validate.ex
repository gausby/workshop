defmodule Workshop.Exercise.Validate do
  alias Workshop.ValidationResult, as: Result

  @spec run(String.t) :: Result.t
  def run(exercise) when is_bitstring(exercise) do
    exercise_module = Workshop.Exercise.load(exercise)

    tests = [
      &should_have_a_title/1,
      &should_have_a_description/1,
      &should_have_a_hint/1
    ]

    for test <- tests, into: %Result{}, do: apply(test, [exercise_module])
  end

  defp should_have_a_title(exercise) do
    title = Workshop.Exercise.get(exercise, :title)
    cond do
      title == nil ->
        {:error, "The exercise #{inspect exercise} should have a title"}
      :otherwise ->
        :ok
    end
  end

  defp should_have_a_description(exercise) do
    description = Workshop.Exercise.get(exercise, :description)
    cond do
      description == nil ->
        {:error, "The exercise #{inspect exercise} should have a description"}
      :otherwise ->
        :ok
    end
  end

  defp should_have_a_hint(exercise) do
    hint = Workshop.Exercise.get(exercise, :hint)
    cond do
      hint == nil ->
        {:error, "The exercise #{inspect exercise} should have a hint"}
      :otherwise ->
        :ok
    end
  end

end
