defmodule Workshop.Validate do
  alias Workshop.ValidationResult, as: Result

  alias Workshop.Exercises
  alias Workshop.Exercise

  @spec run() :: Result.t
  def run do
    tests = [
      &should_have_a_title/0,
      &should_have_a_version/0,
      &should_have_a_description/0,
      &could_have_a_short_description/0,
      &should_have_an_introduction/0,
      &should_have_a_debriefing/0,
      &should_have_at_least_one_exercise/0,
      &should_have_unique_weights_for_exercises/0,
      &should_have_unique_titles_for_exercises/0,
      &should_have_all_valid_exercises/0
    ]

    for test <- tests, into: %Result{}, do: apply(test, [])
  end

  defp should_have_a_title do
    cond do
      Workshop.Info.get(Workshop.Meta, :title) == nil ->
        {:error, "The workshop should have a title"}
      :otherwise ->
        :ok
    end
  end

  defp should_have_a_version do
    cond do
      Workshop.Info.get(Workshop.Meta, :version) == nil ->
        {:error, "The workshop should have a version"}
      :otherwise ->
        :ok
    end
  end

  defp should_have_a_description do
    cond do
      Workshop.Info.get(Workshop.Meta, :description) == nil ->
        {:error, "The workshop should have a description"}
      :otherwise ->
        :ok
    end
  end

  defp could_have_a_short_description do
    shortdesc = Workshop.Info.get(Workshop.Meta, :shortdesc)
    cond do
      shortdesc == false ->
        :ok
      shortdesc == nil ->
        {:warning, "Consider adding a short description to the workshop, " <>
                   "or suppress this warning by setting @shortdesc to `false`"}
      String.length(shortdesc) < 25 ->
        {:error, "Workshop @shortdesc is too short. Please keep it longer than 25 chars."}
      String.length(shortdesc) > 200 ->
        {:error, "Workshop @shortdesc is too long. Please keep it below 200 chars."}
      :otherwise ->
        :ok
    end
  end

  defp should_have_an_introduction do
    cond do
      Workshop.Info.get(Workshop.Meta, :introduction) == nil ->
        {:error, "The workshop should have an introduction"}
      :otherwise ->
        :ok
    end
  end

  defp should_have_a_debriefing do
    cond do
      Workshop.Info.get(Workshop.Meta, :debriefing) == nil ->
        {:error, "The workshop should have a debriefing"}
      :otherwise ->
        :ok
    end
  end

  defp should_have_at_least_one_exercise do
    cond do
      length(Exercises.list!) <= 0 ->
        {:error, "The workshop should have at least one exercise"}
      :otherwise ->
        :ok
    end
  end

  defp should_have_unique_weights_for_exercises do
    exercises =
      Exercises.list_by_weight!
      |> Enum.map(&elem(&1, 0))

    cond do
      length(exercises) != length(Enum.uniq(exercises)) ->
        {:error, "Two or more exercises has the same weight, please make the weights unique"}
      :otherwise ->
        :ok
    end
  end

  defp should_have_unique_titles_for_exercises do
    exercises =
      Exercises.list_by_weight!
      |> Enum.map(&elem(&1, 1))

    cond do
      length(exercises) != length(Enum.uniq(exercises)) ->
        {:error, "Two or more exercises has the same title, please make the titles unique"}
      :otherwise ->
        :ok
    end
  end

  defp should_have_all_valid_exercises do
    Exercises.list!
    |> Enum.map(&Exercise.validate/1)
  end
end
