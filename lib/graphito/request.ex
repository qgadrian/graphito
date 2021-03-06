defmodule Graphito.Request do
  @moduledoc false

  use Tesla, docs: false

  plug(Tesla.Middleware.Tuples)

  alias Graphito.Response

  @default_headers %{"content-type" => "application/graphql"}

  @spec send(String.t(), Graphito.Behaviour.opts()) :: any()
  def send(operation_string, opts \\ []) do
    host = Keyword.get(opts, :url) || Application.get_env(:graphito, :url)
    query = Keyword.get(opts, :query, [])

    headers =
      opts
      |> Keyword.get(:headers, %{})
      |> Map.merge(@default_headers)
      |> Map.merge(Application.get_env(:graphito, :headers, %{}))

    req_opts =
      Keyword.new()
      |> Keyword.put(:query, query)
      |> Keyword.put(:headers, headers)

    host
    |> post(operation_string, req_opts)
    |> Response.handle(opts)
  end
end
