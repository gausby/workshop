defmodule Mix.Tasks.Workshop.Hint do
  use Mix.Task
  alias IO.ANSI.Docs
  alias Workshop.Info
  alias Workshop.Exercise

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {opts, _, _} = OptionParser.parse(argv, switches: [system: :boolean])

    current_exercise = Workshop.Session.get(:current_exercise)
    if current_exercise do
      exercise_module = Exercise.load(current_exercise)
      hints = Exercise.get(exercise_module, :hint)

      Exercise.increment_hint_counter(exercise_module)

      exercise_identifier = Exercise.get_identifer(exercise_module)
      hints_given = Workshop.State.get(:exercises)[exercise_identifier][:hint]
      displayed_hints = hints |> Enum.take(hints_given) |> Enum.map_reduce(1, fn hint, acc ->
        {"#{acc}. #{hint}", acc + 1}
      end) |> elem(0)

      help = cond do
        hints_given != length hints ->
          "Showing #{hints_given} of #{length hints} hints. " <>
          "Type `mix workshop.hint` for more hints."
        :otherwise ->
          "All hints are displayed."
      end

      workshop_title = Info.get(Workshop.Meta, :title)
      exercise_title = Exercise.get(exercise_module, :title)
      Docs.print_heading "#{workshop_title} - #{exercise_title} - Hints", opts
      Docs.print """
      #{displayed_hints}

      #{help}
      """, opts
    else
      Mix.shell.info "This command should get executed from a exercise folder"
    end
  end
end
