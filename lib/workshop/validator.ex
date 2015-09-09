defmodule Workshop.Validator do
  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute __MODULE__, :checks, accumulate: true
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def run, do: Workshop.Validator.Runner.run(@checks, __MODULE__)

      def run(context), do: Workshop.Validator.Runner.run(@checks, __MODULE__, context)
    end
  end

  defmacro verify(description, var \\ quote(do: _), contents) do
    contents =
      case contents do
        [do: block] ->
          quote do
            _ = unquote(block)
          end
        _ ->
          quote do
            _ = try(unquote(contents))
          end
      end

    var = Macro.escape(var)
    contents = Macro.escape(contents, unquote: true)

    quote bind_quoted: binding do
      verify_func = :"verify #{description}"
      Module.put_attribute(__MODULE__, :checks, verify_func)
      def unquote(verify_func)(unquote(var)), do: unquote(contents)
    end
  end
end
