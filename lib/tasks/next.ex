defmodule Mix.Tasks.Workshop.Next do
  use Mix.Task
  alias Workshop.Info
  alias Workshop.Progress

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
    source = Workshop.Session.get(:exercises_folder)
    sandbox = Workshop.Session.get(:folder)
    case Progress.find_next(source, sandbox) do
      :workshop_over ->
        Workshop.run_callback(:on_workshop_completed)
        Mix.shell.info Info.get(Workshop.Meta, :debriefing)

      {:next, exercise} ->
        case Workshop.Exercise.copy_files_to_sandbox(exercise) do
          :ok ->
            Mix.shell.info """
            Go ahead and work in #{exercise}
            """

          {:exists, folder} ->
            Mix.shell.info """
            Please complete the exercise in #{Path.relative_to(folder, sandbox)}

            Type `mix workshop.check` when you are done to verify your solution.
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
