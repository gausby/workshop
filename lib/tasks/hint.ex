defmodule Mix.Tasks.Workshop.Hint do
  use Mix.Task
  alias IO.ANSI.Docs
  alias Workshop.Info
  alias Workshop.Exercise

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {opts, _, _} = OptionParser.parse(argv, switches: [system: :boolean])

    current_exercise = Workshop.State.get(:progress)[:cursor]
    if current_exercise do
      exercise_module = Exercise.load(current_exercise)
      workshop_title = Info.get(Workshop.Meta, :title)
      exercise_title = Exercise.get(exercise_module, :title)
      hints = Exercise.get(exercise_module, :hint)
      number_of_hints = length hints

      exercise_identifier =  Exercise.get_identifer(exercise_module)
      exercises_state = Workshop.State.get(:exercises, [])
      current_exercise_state = exercises_state[exercise_identifier] || []
      new_state = Keyword.update(current_exercise_state, :hint, 1, fn hints_given ->
        if number_of_hints > hints_given do
          hints_given + 1
        else
          hints_given
        end
      end)

      Workshop.State.update(:exercises, Keyword.put(exercises_state, exercise_identifier, new_state))
      Workshop.State.persist!
      hints_given = Workshop.State.get(:exercises)[exercise_identifier][:hint]

      displayed_hints = hints |> Enum.take(hints_given) |> Enum.map_reduce(1, fn hint, acc ->
        {"#{acc}. #{hint}", acc + 1}
      end) |> elem(0)

      help = cond do
        hints_given != number_of_hints ->
          "Showing #{hints_given} of #{number_of_hints} hints. " <>
          "Type `mix workshop.hint` for more hints."
        :otherwise ->
          "All hints are displayed."
      end

      Docs.print_heading "#{workshop_title} - #{exercise_title}", opts
      Docs.print """
      #{displayed_hints}

      #{help}
      """, opts
    else
      Mix.shell.info "The workshop has not been started yet"
    end
  end
end
