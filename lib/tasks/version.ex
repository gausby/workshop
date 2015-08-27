defmodule Mix.Tasks.Workshop.Version do
  use Mix.Task

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {_opts, _, _} = OptionParser.parse(argv, switches: [])

    title = Workshop.Info.get(Workshop.Meta, :title)
    version = Workshop.Info.get(Workshop.Meta, :version)

    Mix.shell.info "#{title} v#{version}"
  end
end
