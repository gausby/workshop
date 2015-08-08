defmodule Mix.Tasks.Workshop.Info do
  use Mix.Task
  alias IO.ANSI.Docs
  alias Workshop.Info
  alias Workshop.Exercise

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {opts, _, _} = OptionParser.parse(argv, switches: [enabled: :boolean])

    workshop_title = Info.get(Workshop.Meta, :title)
    current_exercise = Workshop.State.get(:progress)[:cursor]

    if current_exercise do
      exercise_module = Exercise.load(current_exercise)
      exercise_title = Exercise.get(exercise_module, :title)

      Docs.print_heading "#{workshop_title} - #{exercise_title}", opts
      Docs.print Exercise.get(exercise_module, :description), opts
    else
      Docs.print_heading workshop_title, opts
      Docs.print Info.get(Workshop.Meta, :description), opts
    end
  end
end
