defmodule Workshop.State do
  @doc false
  defmacro __using__(_) do
    quote do
      import Workshop.State, only: [state: 2, state: 3, persist: 0]
      {:ok, agent} = Workshop.State.Agent.start_link
      var!(state_agent, Workshop.State) = agent
    end
  end

  defmacro state(state, opts) do
    quote do
      Workshop.State.Agent.update var!(state_agent, Workshop.State),
        [{unquote(state), unquote(opts)}]
    end
  end

  defmacro state(state, key, opts) do
    quote do
      Workshop.State.Agent.update var!(state_agent, Workshop.State),
        [{unquote(state), [{unquote(key), unquote(opts)}]}]
    end
  end

  @doc """
  Persist the current state to disk. This has to be called when the state
  should be committed.
  """
  defmacro persist do
    quote do
      state = Workshop.State.Agent.get(var!(state_agent, Workshop.State))
              |> Macro.to_string

      Path.expand("state.exs")
      |> File.write(state)
    end
  end

  @doc """
  Read and parse the state from disk.
  """
  def import_state do
    state_file = Path.expand("state.exs")
    if File.exists? state_file do
      {state, _binding} = Code.eval_file(state_file)
      state
    else
      []
    end
  end

  @doc """
  Update the current state of the workshop.
  """
  def update(state, update) do
    Keyword.merge(state, update, fn(_key, value1, value2) ->
      Keyword.merge(value1, value2, &deep_merge/3)
    end)
  end

  defp deep_merge(_key, value1, value2) do
    if Keyword.keyword?(value1) and Keyword.keyword?(value2) do
      Keyword.merge(value1, value2, &deep_merge/3)
    else
      value2
    end
  end
end
