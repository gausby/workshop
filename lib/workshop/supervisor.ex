defmodule Workshop.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    {:ok, workshop_folder} = Workshop.locate_root

    children = [
      worker(Workshop.Session, [workshop_folder, [name: Workshop.Session]]),
      worker(Workshop.State, [[name: Workshop.State]])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
