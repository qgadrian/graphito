defmodule GraphitoTest.Jedi do
  @moduledoc false
  defstruct [:name, :surname, friends: []]
end

defmodule GraphitoTest do
  @moduledoc false

  use ExUnit.Case

  import Tesla.Mock

  @mock_data_luke %{"name" => "Luke", "surname" => "Skywalker"}
  @mock_data_luke_struct %GraphitoTest.Jedi{name: "Luke", surname: "Skywalker"}
  @mock_data_leia %{"name" => "Leia", "surname" => "Organa", "friends" => [@mock_data_luke]}
  @mock_data_leia_struct %GraphitoTest.Jedi{
    name: "Leia",
    surname: "Organa",
    friends: [@mock_data_luke_struct]
  }
  @jedi_as_struct %GraphitoTest.Jedi{friends: [%GraphitoTest.Jedi{}]}

  @default_reason :an_error
  @default_error_message %{"message" => "an_error"}

  describe "Given a document query" do
    test "when the query is sucessful then the result is returned" do
      mock(fn _ ->
        %Tesla.Env{
          status: 200,
          body: Poison.encode!(%{"data" => @mock_data_luke})
        }
      end)

      assert Graphito.run("a_query") == sucess_response()
    end

    test "when should convert the response then a struct with the result data is returned" do
      mock(fn _ ->
        %Tesla.Env{
          status: 200,
          body: Poison.encode!(%{"data" => @mock_data_luke})
        }
      end)

      assert Graphito.run("a_query", as: @jedi_as_struct) ==
               sucess_response(@mock_data_luke_struct)
    end

    test "when should convert a list response then a struct list with the results data is returned" do
      mock(fn _ ->
        %Tesla.Env{
          status: 200,
          body: Poison.encode!(%{"data" => [@mock_data_luke, @mock_data_leia]})
        }
      end)

      assert Graphito.run("a_query", as: @jedi_as_struct) ==
               sucess_response([@mock_data_luke_struct, @mock_data_leia_struct])
    end

    test "when using opts then they are using in the request" do
      mock(fn %{
                method: :post,
                url: "a_host",
                query: [a_key: "a_value"],
                headers: %{"a_header" => "a_value", "content-type" => "application/graphql"}
              } ->
        %Tesla.Env{
          status: 200,
          body: Poison.encode!(%{"data" => @mock_data_luke})
        }
      end)

      assert Graphito.run(
               "a_query",
               url: "a_host",
               query: [a_key: "a_value"],
               headers: %{"a_header" => "a_value"}
             ) == sucess_response()
    end
  end

  describe "Given a failing query" do
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
          body: Poison.encode!(%{"data" => @mock_data_luke})
        }
      end)

      assert Graphito.run("a_query") == sucess_response()
    end

    test "when the response code is not a 200 then an error is returned" do
      mock(fn %{method: :post} ->
        %Tesla.Env{status: 223, body: "an error happen"}
      end)

      assert Graphito.run("a_query") ==
               error_response(
                 reason: 223,
                 errors: [%{"message" => "Unable to parse error response: an error happen"}]
               )
    end

    test "when an error response have the configured error keys to fetch then an error with the configured keys is returned" do
      mock(fn %{method: :post} ->
        %Tesla.Env{
          status: 503,
          body:
            Poison.encode!(%{
              "data" => nil,
              "errors" => [%{"message" => "an_error", "code" => "a_code"}]
            })
        }
      end)

      assert Graphito.run("a_query") ==
               error_response(
                 reason: 503,
                 errors: [%{"message" => "an_error", "code" => "a_code"}]
               )
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

  defp sucess_response(data \\ @mock_data_luke) do
    {
      :ok,
      %Graphito.Response{
        data: data,
        status: 200,
        errors: nil,
        headers: %{}
      }
    }
  end
end
