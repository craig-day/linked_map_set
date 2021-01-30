defmodule LinkedMapSet.Node do
  @moduledoc false

  @enforce_keys [:value]
  defstruct [:value, :previous, :next]

  @typedoc false
  @type t :: %__MODULE__{value: any(), previous: any(), next: any()}
end
