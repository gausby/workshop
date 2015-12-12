defmodule Workshop.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(_opts) do
    children = [
      session_worker(Workshop.locate_root),
      worker(Workshop.State, [[name: Workshop.State]])
    ]
    supervise(children, strategy: :one_for_one)
  end

  defp session_worker({:ok, workshop_folder, exercise}),
    do: worker(Workshop.Session, [workshop_folder, exercise, [name: Workshop.Session]])
  defp session_worker({:ok, workshop_folder}),
    do: worker(Workshop.Session, [workshop_folder, nil, [name: Workshop.Session]])
  defp session_worker({:error, reason}),
    do: raise(reason)
end
