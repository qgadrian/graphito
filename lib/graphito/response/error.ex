defmodule Graphito.Response.Error do
  @moduledoc false

  @type t :: %__MODULE__{
          reason: any(),
          errors: list(String.t())
        }

  defstruct reason: nil,
            errors: nil
end
