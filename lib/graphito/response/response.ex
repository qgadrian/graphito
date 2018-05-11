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
    response_data = Poison.decode!(response.body)

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
    with {:ok, response_data} <- Poison.decode(response.body) do
      {
        :error,
        %Error{
          reason: response.status,
          errors: Map.get(response_data, "errors")
        }
      }
    else
      _ ->
        {
          :error,
          %Error{
            reason: response.status,
            errors: [%{"message" => "Unable to parse error response: #{response.body}"}]
          }
        }
    end
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
end
