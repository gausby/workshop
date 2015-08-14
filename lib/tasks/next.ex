defmodule Mix.Tasks.Workshop.Next do
  use Mix.Task
  alias Workshop.Info

  def run(_) do
    Workshop.start([], [])

    case perform_system_and_workshop_check do
      {:error, reason} ->
        Mix.shell.error reason
      :ok ->
        progress_to_next
    end
  end

  defp progress_to_next do
    case Workshop.Exercises.find_next! do
      :workshop_over ->
        Mix.shell.info Info.get(Workshop.Meta, :debriefing)

      {:next, exercise} ->
        case Workshop.Exercise.copy_files_to_sandbox(exercise) do
          :ok ->
            Workshop.State.update(:progress, cursor: exercise)
            Workshop.State.persist!
            Mix.shell.info """
            Go ahead and work in #{exercise}
            """
          {:error, reason} ->
            Mix.shell.error """
            Setting up the next exercise failed with the following message:

            #{reason}

            Try running `mix workshop.doctor` or `mix workshop.validate`
            """
            System.at_exit fn _ ->
              exit({:shutdown, 1})
            end
        end
    end
  end

  # system and workshop validation helpers
  defp perform_system_and_workshop_check do
    cond do
      Workshop.State.state_file_exists? ->
        # assume everything is fine if the state file has been created
        :ok
      fail_doctor? ->
        {:error, """
        The system does not yet fit the requirements for this workshop.

        Please run the command:

        `mix workshop.doctor`

        To get a report on what is missing.
        """}
      fail_workshop_validation? ->
        {:error, """
        This does not appear to be a valid workshop. Please run the command:

        `mix workshop.validate`

        This will display the validation results.
        """}
      :otherwise ->
        # should perhaps fast forward through the already solved exercises
        # by running the solution check on exercise solutions if they exist;
        # it should then move the exercise state cursor to the first exercise
        # folder that fail the solution check or has not been created yet
        :ok
    end
  end

  defp fail_doctor? do
    case Workshop.doctor do
      %{runs: x, passed: x} ->
        false
      _ ->
        true
    end
  end

  defp fail_workshop_validation? do
    case Workshop.validate do
      %{runs: x, passed: x} ->
        false
      _ ->
        true
    end
  end
end
