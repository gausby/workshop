defmodule Mix.Tasks.Workshop do
  use Mix.Task

  alias Workshop.Info
  alias Workshop.Exercise
  alias Workshop.Exercises
  alias IO.ANSI.Docs

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {opts, _, _} = OptionParser.parse(argv, switches: [enabled: :boolean])

    short_description = Info.get(Workshop.Meta, :shortdesc) || nil

    Docs.print_heading Info.get(Workshop.Meta, :title), opts
    Docs.print """
    #{short_description}

    #{list_exercises}

    Type `mix workshop.info` for information about this workshop.
    Type `mix workshop.help` if you need help.
    """, opts
  end

  @status %{
    not_started: "",
    in_progress: "- IN PROGRESS",
    completed: "- COMPLETED"
  }

  defp list_exercises do
    current_exercise = Workshop.Session.get(:current_exercise)
    progress = Workshop.State.get(:exercises, [])

    Exercises.list_by_weight!
    |> Enum.with_index
    |> Enum.map(fn {{_weight, exercise}, index} ->
         module = Exercise.load(exercise)
         %{number: index + 1,
           title: Exercise.get(module, :title),
           status: progress[Exercise.get_identifier(module)][:status],
           current: Path.basename(exercise) == current_exercise}
       end)
    |> Enum.map(fn
         %{current: true} = e ->
           "  #{e.number}. *#{e.title} #{@status[e.status]}*\n"
         e ->
           "  #{e.number}. #{e.title} #{@status[e.status]}\n"
       end)
  end
end
