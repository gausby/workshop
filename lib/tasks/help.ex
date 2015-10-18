defmodule Mix.Tasks.Workshop.Help do
  use Mix.Task
  alias IO.ANSI.Docs

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    Workshop.start([], [])
    {opts, _, _} = OptionParser.parse(argv, switches: [system: :boolean])
    title = Workshop.Info.get(Workshop.Meta, :title)
    version = Workshop.Info.get(Workshop.Meta, :version)

    help = cond do
      Workshop.Info.get(Workshop.Meta, :home) == nil ->
        nil
      String.starts_with?(Workshop.Info.get(Workshop.Meta, :home), "https://github.com/") ->
        """
        If something is unclear or you need further help you could try
        browsing the already asked questions in the GitHub issues for this
        workshop:

          * #{Workshop.Info.get(Workshop.Meta, :home)}/issues
        """
      home = Workshop.Info.get(Workshop.Meta, :home) ->
        """
        Visit *#{home}* for more information about this workshop.
        """
    end

    Docs.print_heading "#{title} v#{version} - Help", opts
    Docs.print """
    Please make sure that your system is ready for the workshop by using
    the `mix workshop.doctor` command. Also, the `mix workshop.validate`
    command can tell you if the workshop itself is ready for running.

    Your progress can be displayed by simply typing `mix workshop` in the
    terminal.

    The exercise description of the current exercise can be displayed using
    the `mix workshop.info` command, and the solution can be verified with
    the `mix workshop.check` command.

    If a solution is valid the `mix workshop.next` command can be used to
    checkout and progress to the next exercise.

    If you are stuck in an exercise you could try the `mix workshop.hint`
    command, which will give you a hint about completing the exercise.

    #{help}
    """, opts
  end
end
