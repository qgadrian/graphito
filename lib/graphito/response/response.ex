defmodule Graphito.Response do
  @moduledoc """
  Reponse from a GraphQL request.
  """

  use Graphito.Util.StructMapper

  alias Graphito.Response.Error

  @typedoc """
  The response finormation from a GraphQL operation:

    - data: The data response
    - errors: The errors response
    - status: The HTTP status from the server response
    - headers: The HTTP headers sent in the server response
  """
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

  @spec handle({:ok, Tesla.Env.t()}, keyword) :: {:ok, t()}
  def handle({:ok, %{status: 200} = response}, opts) do
    response_body = Poison.decode!(response.body)

    response_data = Map.get(response_body, "data", %{})

    data =
      case opts[:as] do
        nil ->
          response_data

        %_{} = struct ->
          case response_data do
            data when is_list(data) ->
              response.body
              |> Poison.decode!(as: %{"data" => [struct]})
              |> Map.get("data", [])

            _ ->
              response.body
              |> Poison.decode!(as: %{"data" => struct})
              |> Map.get("data", %{})
          end

        invalid_struct ->
          raise "Invalid struct: #{inspect(invalid_struct)}"
      end

    {
      :ok,
      %__MODULE__{
        status: response.status,
        data: data,
        errors: Map.get(response_body, "errors"),
        headers: response.headers
      }
    }
  end

  def handle({:ok, response}, _opts) do
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

  @spec handle({:error, %{reason: any}}, keyword) :: {:error, Error.t()}
  def handle({:error, response}, _opts) do
    {
      :error,
      %Error{
        reason: response.reason,
        errors: [%{"message" => "Failed to fetch GraphQL response"}]
      }
    }
  end
end
