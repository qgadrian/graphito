defmodule Graphito.Util.StructMapper do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      @spec to_struct(any, map) :: struct
      defp to_struct(kind, attrs) do
        struct = struct(kind)

        Enum.reduce(Map.to_list(struct), struct, fn {key, _}, acc ->
          attrs
          |> Map.fetch(Atom.to_string(key))
          |> case do
            {:ok, value} -> %{acc | key => value}
            :error -> acc
          end
        end)
      end
    end
  end
end
