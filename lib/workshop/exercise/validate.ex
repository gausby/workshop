defmodule Workshop.Exercise.Validate do
  alias Workshop.ValidationResult, as: Result

  @spec run(String.t) :: Result.t
  def run(exercise) when is_bitstring(exercise) do
    exercise_module = Workshop.Exercise.load(exercise)

    tests = [
      &should_have_a_title/1
    ]

    for test <- tests, into: %Result{}, do: apply(test, [exercise_module])
  end

  defp should_have_a_title(exercise) do
    title = Workshop.Exercise.get(exercise, :title)
    cond do
      title == nil ->
        {:error, "The workshop should have a title"}
      :otherwise ->
        :ok
    end
  end
end
