defmodule GraphitoTest do
  @moduledoc false

  use ExUnit.Case

  import Tesla.Mock

  @fake_data %{"some" => "data"}

  @default_reason :an_error
  @default_error_message %{"message" => "an_error"}

  describe "Given a document query" do
    test "when it is not valid then an error is returned" do
      invalid_query_error =
        error_response(reason: :invalid_operation, errors: [%{"mesage" => "Invalid operation"}])

      assert Graphito.run(nil) == invalid_query_error
      assert Graphito.run(23) == invalid_query_error
      assert Graphito.run(%{}) == invalid_query_error
    end

    test "when it is valid then the response document is returned" do
      mock(fn %{method: :post} ->
        %Tesla.Env{
          status: 200,
          body: Poison.encode!(%{"data" => @fake_data})
        }
      end)

      assert Graphito.run("a_query") == sucess_response()
    end

    test "when the response code is not a 200 then an error is returned" do
      error_body = %{"data" => nil, "errors" => [@default_error_message]}

      mock(fn %{method: :post} ->
        %Tesla.Env{status: 223, body: Poison.encode!(error_body)}
      end)

      assert Graphito.run("a_query") ==
               error_response(reason: 223, errors: [%{"message" => error_body}])
    end

    test "when using opts then the opts are using in the request" do
      mock(fn %{
                method: :post,
                url: "a_host",
                query: [a_key: "a_value"],
                headers: [{"a_header", "a_value"}, {"content-type", "application/graphql"}]
              } ->
        %Tesla.Env{
          status: 200,
          body: Poison.encode!(%{"data" => @fake_data})
        }
      end)

      assert Graphito.run(
               "a_query",
               url: "a_host",
               query: [a_key: "a_value"],
               headers: [{"a_header", "a_value"}]
             ) == sucess_response()
    end
  end

  defp error_response(opts) do
    {
      :error,
      %Graphito.Response.Error{
        reason: opts[:reason] || @default_reason,
        errors: opts[:errors] || [@default_error_message]
      }
    }
  end

  defp sucess_response do
    {
      :ok,
      %Graphito.Response{
        data: @fake_data,
        status: 200,
        errors: nil,
        headers: []
      }
    }
  end
end
