defmodule Graphito.Behaviour do
  @moduledoc """
  Behaviour for Graphite client.
  """

  @typedoc """
  Options for a operation:

  - headers: List of headers that will be send in the request.
  - query: Query params.
  - url: The GraphQL host url.
  """
  @type opts :: [
          headers: Keyword.t(),
          query: Keyword.t(),
          url: String.t()
        ]

  @callback run(String.t(), opts()) ::
              {:ok, Graphito.Response.t()} | {:error, Graphito.Response.Error.t()}
end

defmodule Graphito do
  @moduledoc """
  Graphito GraphQL client.
  """

  @behaviour Graphito.Behaviour

  alias Graphito.Request
  alias Graphito.Response.Error

  @impl true
  @doc """
  Executes a GraphQL query.

  It supports different request options, see `t:Graphito.Behaviour.opts/0` for details.

  ## Examples:

      iex> Graphito.run("query { jedis { name }}", url: "a_host", query: [a_key: "a_value"], headers: [{"a_header", "a_value"}])
      %Graphito.Response{data: %{"jedis" => [%{"name" => "luke"}, %{"name" => "leia"}]}, status: 200, errors: nil, headers: []}

      iex> Graphito.run("query { jedis { namez }}", url: "a_host", query: [a_key: "a_value"], headers: [{"a_header", "a_value"}])
      %Graphito.Response{data: nil, status: 200, errors: [%{"message" => "Cannot query field \"namez\" on type \"Jedi\". Did you mean \"name\"?"}], headers: [{"content-type", "application/json"}]}
  """
  def run(operation_string, opts \\ [])

  def run(operation_string, _opts) when not is_binary(operation_string) do
    {
      :error,
      %Error{
        reason: :invalid_operation,
        errors: [%{"mesage" => "Invalid operation"}]
      }
    }
  end

  def run(operation_string, opts) do
    Request.send(operation_string, opts)
  end
end
