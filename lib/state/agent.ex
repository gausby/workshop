defmodule Workshop.State.Agent do
  @moduledoc false
  @type state :: Keyword.t

  @spec start_link() :: {:ok, pid}
  def start_link do
    Agent.start_link fn -> Workshop.State.import_state end
  end

  @spec stop(pid) :: :ok
  def stop(agent) do
    Agent.stop(agent)
  end

  @spec get(pid) :: state
  def get(agent) do
    Agent.get(agent, &(&1))
  end

  @spec update(pid, state) :: state
  def update(agent, new_state) do
    Agent.update(agent, &Workshop.State.update(&1, new_state))
  end
end
