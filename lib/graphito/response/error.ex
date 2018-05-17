defmodule Graphito.Response.Error do
  @moduledoc """
  A graphito error reponse.
  """

  @typedoc """
  Error information for a GraphQL operation:

    - reason: A non GraphQL realted error, for example a server HTTP code error.
    - errors: The list of errors sent by the GraphQL server.
  """
  @type t :: %__MODULE__{
          reason: any(),
          errors: list(String.t())
        }

  defstruct reason: nil,
            errors: nil
end
