defmodule Workshop.Exercise.Validate do
  use Workshop.Validator

  verify "Should have a title", %{mod: exercise} do
    title = Workshop.Exercise.get(exercise, :title)
    cond do
      title == nil ->
        {:error, "The exercise #{inspect exercise} should have a title"}
      :otherwise ->
        :ok
    end
  end

  verify "Should have a description", %{mod: exercise} do
    description = Workshop.Exercise.get(exercise, :description)
    cond do
      description == nil ->
        {:error, "The exercise #{inspect exercise} should have a description"}
      :otherwise ->
        :ok
    end
  end

  verify "should have a hint", %{mod: exercise} do
    hint = Workshop.Exercise.get(exercise, :hint)
    cond do
      hint == nil ->
        {:error, "The exercise #{inspect exercise} should have a hint"}
      :otherwise ->
        :ok
    end
  end
end
