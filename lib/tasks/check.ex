defmodule Mix.Tasks.Workshop.Check do
  use Mix.Task

  @prerequisite_file_name "prerequisite.exs"

  defp prerequisite_file(folder),
  do: Path.join(folder, @prerequisite_file_name)

  defp execute_prerequisite_check(path) do
    if File.exists? path do
      # compile and execute the run function on the first found module
      prerequisite = Code.load_file(path) |> hd |> elem(0)
      prerequisite.run()
    else
      {:ok, "no prerequisites defined"}
    end
  end

  @spec run(OptionParser.argv) :: :ok
  def run(argv) do
    {opts, _, _} = OptionParser.parse(argv, switches: [system: :boolean])
    if opts[:system] do
      path = prerequisite_file("./sample")
      {_, reason} = execute_prerequisite_check(path)
      Mix.shell.info reason
    else
      # todo
    end
  end
end
