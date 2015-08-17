defmodule Workshop.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    case Workshop.locate_root do
      {:ok, root} ->
        workshop_folder = root
      {:ok, root, exercise} ->
        workshop_folder = root
        exercise = exercise
    end

    children = [
      worker(Workshop.Session, [workshop_folder, exercise, [name: Workshop.Session]]),
      worker(Workshop.State, [[name: Workshop.State]])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
