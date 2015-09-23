defmodule Workshop.Exercise.Validate do
  use Workshop.Validator

  alias Workshop.Exercise

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

  verify "The existence of an exercise task", %{mod: exercise} do
    task = Workshop.Exercise.get(exercise, :task)
    cond do
      task == nil ->
        {:error, "The exercise #{inspect exercise} should have a task"}
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

  verify "The existence of exercise and solution files", %{exercise: exercise, mod: mod} do
    solution_folder = Exercise.solution_folder(exercise)
    cond do
      File.ls!(Exercise.files_folder(exercise)) == [] ->
        {:error, "The exercise #{inspect mod} did not have any exercise files in its files folder"}

      File.ls!(solution_folder) == [] ->
        {:error, "The exercise #{inspect mod} did not provide a solution"}

      :otherwise ->
        # check if the provided solution satisfies the solution checker
        exercise_folder = Path.expand(exercise, Workshop.Session.get(:exercises_folder))
        case Exercise.check_solution(solution_folder, exercise_folder) do
          %Workshop.Validator.Result{runs: x, passed: x} ->
            :ok
          _ ->
            {:error, "The exercise #{inspect exercise} did not have a solution that passes the exercise solution check"}
        end
    end
  end
end
