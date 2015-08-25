defmodule Mix.Tasks.Workshop.Check do
  use Mix.Task
  alias Workshop.Exercise
  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {_opts, _, _} = OptionParser.parse(argv, switches: [system: :boolean])

    current_exercise = Workshop.Session.get(:current_exercise)
    if current_exercise do
      exercise = Exercise.load current_exercise
      exercises_state = Workshop.State.get(:exercises, [])
      identifier = Exercise.get_identifier(exercise)

      current_exercise_state = exercises_state[identifier] || []
      new_state = Keyword.put(current_exercise_state, :status, :completed)

      Workshop.State.update(:exercises, Keyword.put(exercises_state, identifier, new_state))
      Workshop.State.persist!

      Mix.shell.info "Marked as completed!"
    else
      Mix.shell.info "This command should get executed from within an exercise folder"
    end
  end
end
