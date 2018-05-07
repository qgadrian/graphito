defmodule Graphito.Request do
  @moduledoc false

  use Tesla, docs: false

  alias Graphito.Response

  @default_headers [{"content-type", "application/graphql"}]

  @spec send(String.t(), Graphito.Behaviour.opts()) :: any()
  def send(operation_string, opts \\ []) do
    host = Keyword.get(opts, :url) || Application.get_env(:graphito, :url)
    query = Keyword.get(opts, :query, [])

    headers =
      Keyword.get(opts, :headers, []) ++
        @default_headers ++ Application.get_env(:graphito, :headers, [])

    opts =
      Keyword.new()
      |> Keyword.put(:query, query)
      |> Keyword.put(:headers, headers)

    host
    |> post(operation_string, opts)
    |> Response.handle()
  end
end
