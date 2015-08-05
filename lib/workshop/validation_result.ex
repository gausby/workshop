defmodule Workshop.ValidationResult do
  defstruct errors: [], warnings: [], runs: 0, passed: 0

  @doc false
  def into(original) do
    {original, fn
      source, {:cont, {:error, error}} ->
        %__MODULE__{source|runs: source.runs + 1, errors: [error|source.errors]}

      source, {:cont, {:warning, warning}} ->
        %__MODULE__{source|runs: source.runs + 1, passed: source.passed + 1, warnings: [warning|source.warnings]}

      source, {:cont, :ok} ->
        %__MODULE__{source|runs: source.runs + 1, passed: source.passed + 1}

      source, :done ->
        source

      _source, :halt ->
        :ok
    end}
  end
end

defimpl Collectable, for: Workshop.ValidationResult do
  defdelegate into(original), to: Workshop.ValidationResult
end
