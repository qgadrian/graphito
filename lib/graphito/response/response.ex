defmodule Graphito.Response do
  @moduledoc false

  alias Graphito.Response.Error

  @type t :: %__MODULE__{
          data: map(),
          status: non_neg_integer,
          errors: list(),
          headers: map()
        }

  @enforce_keys [
    :data,
    :errors,
    :status,
    :headers
  ]

  defstruct @enforce_keys

  @spec handle({:ok, Tesla.Env.t()}) :: {:ok, t()}
  def handle({:ok, %{status: 200} = response}) do
    response_data = parse_body(response)

    {
      :ok,
      %__MODULE__{
        status: response.status,
        data: Map.get(response_data, "data", %{}),
        errors: Map.get(response_data, "errors"),
        headers: response.headers
      }
    }
  end

  def handle({:ok, response}) do
    {
      :error,
      %Error{
        reason: response.status,
        errors: [%{"message" => parse_body(response)}]
      }
    }
  end

  @spec handle({:error, %{reason: any()}}) :: {:error, Error.t()}
  def handle({:error, response}) do
    {
      :error,
      %Error{
        reason: response.reason,
        errors: [%{"message" => "Failed to fetch GraphQL response"}]
      }
    }
  end

  defp parse_body(response), do: Poison.decode!(response.body)
end
