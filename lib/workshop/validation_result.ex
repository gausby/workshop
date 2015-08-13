defmodule Workshop.ValidationResult do
  defstruct errors: [], warnings: [], runs: 0, passed: 0

  @doc false
  def into(original) do
    {original, fn
      source, {:cont, {:error, error}} ->
        %__MODULE__{source|errors: [error|source.errors],
                           runs: source.runs + 1}

      source, {:cont, {:warning, warning}} ->
        %__MODULE__{source|warnings: [warning|source.warnings],
                           passed: source.passed + 1,
                           runs: source.runs + 1}

      source, {:cont, results} when is_list(results) ->
        Enum.reduce(results, source, fn %__MODULE__{} = result, acc ->
          %__MODULE__{acc|errors: acc.errors ++ result.errors,
                          warnings: acc.warnings ++ result.warnings,
                          runs: acc.runs + result.runs,
                          passed: acc.passed + result.passed}
        end)

      source, {:cont, :ok} ->
        %__MODULE__{source|runs: source.runs + 1, passed: source.passed + 1}

      source, :done ->
        %__MODULE__{source|errors: Enum.reverse(source.errors),
                           warnings: Enum.reverse(source.warnings)}

      _source, :halt ->
        :ok
    end}
  end
end

defimpl Collectable, for: Workshop.ValidationResult do
  defdelegate into(original), to: Workshop.ValidationResult
end
