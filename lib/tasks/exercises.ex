defmodule Mix.Tasks.Workshop.Exercises do
  use Mix.Task
  alias IO.ANSI.Docs

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    {opts, _, _} = OptionParser.parse(argv, switches: [enabled: :boolean])
    path = "sample/"
    metadata = Workshop.info(path)

    exercises = Workshop.find_exercise_folders(path)
             |> Enum.with_index
             |> Enum.map(fn {item, index} -> "\n#{index + 1}. #{item}" end)

    Docs.print_heading metadata.workshop[:title], opts
    Docs.print """
    #{exercises}
    """, opts

    :ok
  end
end
