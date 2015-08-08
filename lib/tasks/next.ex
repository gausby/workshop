defmodule Mix.Tasks.Workshop.Next do
  use Mix.Task
  import Workshop.Info

  def run(_) do
    Workshop.start([], [])

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
end
