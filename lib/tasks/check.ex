defmodule Mix.Tasks.Workshop.Check do
  use Mix.Task

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {_opts, _, _} = OptionParser.parse(argv, switches: [system: :boolean])

    current_exercise = Workshop.Session.get(:current_exercise)
    if current_exercise do
      Mix.shell.info "todo, run acceptance test!"
    else
      Mix.shell.info "This command should get executed from within an exercise folder"
    end
  end
end
