defmodule Workshop.Session do
  @moduledoc false
  @name __MODULE__

  @doc false
  def start_link(opts) do
    Agent.start_link(__MODULE__, :init, [], opts)
  end

  @doc """
  Initialize the session agent.
  """
  def init() do
    workshop_folder = Workshop.Utils.find_workshop_folder!
    [
      folder: workshop_folder,
      data_folder: workshop_folder |> Path.join(".workshop"),
      exercises_folder: workshop_folder |> Path.join(".workshop") |> Path.join("exercises")
    ]
  end

  @doc """
  Stop the session agent.
  """
  def stop do
    Agent.stop(@name)
  end

  @doc """
  Get value on a given `key` from the session agent. A `default` value can be
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
end
