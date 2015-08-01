defmodule Workshop.State do
  @moduledoc false
  @name __MODULE__

  @doc false
  def start_link(opts) do
    Agent.start_link(__MODULE__, :init, [], opts)
  end

  @doc """
  Initialize the state agent with data from `.workshop/state.exs`, or an
  empty keyword list if that file does not exist.
  """
  def init() do
    state_file = Workshop.Session.get(:data_folder) |> Path.join("state.exs")

    if File.exists? state_file do
      {state, _binding} = Code.eval_file(state_file)
      state
    else
      []
    end
  end

  @doc """
  Stop the state agent.
  """
  def stop do
    Agent.stop(@name)
  end

  @doc """
  Get value on a given `key` from the state agent. A `default` value can be
  set if needed.
  """
  def get(key, default \\ nil) do
    Agent.get(@name, Keyword, :get, [key, default])
  end

  @doc """
  Put a `value` on the given `key`. This will overwrite the keys current
  value.
  """
  def put(key, value) do
    Agent.update(@name, Keyword, :put, [key, value])
  end

  @doc """
  Update the given key with the given data. If the key holds a keyword list,
  and the data is a keyword list the two will get merged.
  """
  def update(key, data) do
    Agent.update(@name, Keyword, :update, [key, data, fn state ->
      Keyword.merge(state, data, &do_deep_merge/3)
    end])
  end
  # merge two keyword lists, or overwrite if one of the two is not a keyword list
  defp do_deep_merge(_key, value1, value2) do
    if Keyword.keyword?(value1) and Keyword.keyword?(value2) do
      Keyword.merge(value1, value2, &do_deep_merge/3)
    else
      value2
    end
  end

  @doc """
  Commit the data to disk. Will raise an exception if the write failed.
  """
  def persist! do
    Workshop.Session.get(:data_folder)
    |> Path.join("state.exs")
    |> File.write(Macro.to_string(Agent.get(@name, &(&1))))
  end
end
