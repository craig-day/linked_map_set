defmodule LinkedMapSet do
  @moduledoc """
  A `LinkedMapSet` is an extension to `MapSet` that keeps pointers to previous
  and next elements based on add order.
  """
  alias LinkedMapSet.{DuplicateValueError, MissingValueError}
  alias LinkedMapSet.Node

  @enforce_keys [:items]
  defstruct head: nil, tail: nil, items: %{}

  @type t :: %__MODULE__{head: any(), tail: any(), items: map()}

  @doc """
  Create a new `LinkedMapSet`

  Returns a new empty `LinkedMapSet`.

  ## Examples

      iex> LinkedMapSet.new()
      %LinkedMapSet{head: nil, items: %{}, tail: nil}
  """
  @spec new :: LinkedMapSet.t()
  def new(), do: %__MODULE__{items: %{}}

  @doc """
  Adds an item to the linked map, or moves an existing one to tail.

  Returns the updated `LinkedMapSet`.

  ## Examples

      iex> LinkedMapSet.new() |> LinkedMapSet.add("foo")
      iex> LinkedMapSet.new |> LinkedMapSet.add("foo") |> LinkedMapSet.add("bar")
      %LinkedMapSet{
        head: "foo",
        items: %{
          "bar" => %Node{next: nil, previous: "foo", value: "bar"},
          "foo" => %Node{next: "bar", previous: nil, value: "foo"}
        },
        tail: "bar"
      }
  """
  @spec add(__MODULE__.t(), any) :: __MODULE__.t()
  def add(linked_map_set, value)

  def add(%__MODULE__{head: nil, tail: nil, items: %{}}, value) do
    new_node = %Node{value: value}

    %__MODULE__{head: value, tail: value, items: %{value => new_node}}
  end

  def add(%__MODULE__{head: head, tail: tail} = lms, value) do
    if head == tail do
      if head == value, do: lms, else: add_second_item(lms, value)
    else
      add_nth_item(lms, value)
    end
  end

  defp add_second_item(%__MODULE__{head: head}, value) do
    second_node = %Node{value: value, previous: head}
    first_node = %Node{value: head, next: second_node.value}

    items = %{
      first_node.value => first_node,
      second_node.value => second_node
    }

    %__MODULE__{head: first_node.value, tail: second_node.value, items: items}
  end

  defp add_nth_item(%__MODULE__{tail: tail, items: items} = lms, value) do
    new_node = %Node{value: value, previous: tail}
    clean_items = if Map.has_key?(items, value), do: remove(lms, value).items, else: items
    replacement_tail = %{clean_items[tail] | next: new_node.value}

    updated_items =
      clean_items
      |> Map.put(tail, replacement_tail)
      |> Map.put(new_node.value, new_node)

    %{lms | tail: new_node.value, items: updated_items}
  end

  @doc """
  Adds a new item to the linked map, unless it already exists.

  Returns the updated `LinkedMapSet`.

  ## Examples

      iex> LinkedMapSet.new() |> LinkedMapSet.add("a") |> LinkedMapSet.add_new("a")
      %LinkedMapSet{
        head: "a",
        items: %{
          "a" => %Node{next: nil, previous: nil, value: "a"}
        },
        tail: "a"
      }
  """
  @spec add_new(__MODULE__.t(), any) :: __MODULE__.t()
  def add_new(linked_map_set, value)

  def add_new(%__MODULE__{items: items} = lms, value) do
    if Map.has_key?(items, value) do
      lms
    else
      add(lms, value)
    end
  end

  @doc """
  Adds a new item to the linked map, or raises if `value` already exists.

  Returns the updated `LinkedMapSet` or raises if `value` already exists.

  Behaves the same as `add_new/2` but raises if `value` already exists.

  ## Examples

      iex> LinkedMapSet.new() |> LinkedMapSet.add("a") |> LinkedMapSet.add_new!("a")
      ** (LinkedMapSet.DuplicateValueError) value "a" is already present
  """
  @spec add_new!(__MODULE__.t(), any) :: __MODULE__.t()
  def add_new!(%__MODULE__{items: items} = lms, value) do
    if Map.has_key?(items, value) do
      raise DuplicateValueError, value: value
    else
      add(lms, value)
    end
  end

  @doc """
  Remove an item from the linked map if it exists.

  Returns the updated `LinkedMapSet`.

  ## Examples

      iex> linked_map_set = LinkedMapSet.new |> LinkedMapSet.add("a") |> LinkedMapSet.add("b") |> LinkedMapSet.add("c")
      %LinkedMapSet{
        head: "a",
        items: %{
          "a" => %Node{next: "b", previous: nil, value: "a"},
          "b" => %Node{next: "c", previous: "a", value: "b"},
          "c" => %Node{next: nil, previous: "b", value: "c"}
        },
        tail: "c"
      }
      iex> LinkedMapSet.remove(linked_map_set, "b")
      %LinkedMapSet{
        head: "a",
        items: %{
          "a" => %Node{next: "c", previous: nil, value: "a"},
          "c" => %Node{next: nil, previous: "a", value: "c"}
        },
        tail: "c"
      }
  """
  @spec remove(__MODULE__.t(), any) :: __MODULE__.t()
  def remove(linked_map_set, value)

  def remove(%__MODULE__{head: head, tail: tail, items: items} = lms, value) do
    cond do
      !Map.has_key?(items, value) ->
        lms

      head == value && tail == value ->
        new()

      head == value ->
        remove_first_item(lms, value)

      tail == value ->
        remove_last_item(lms, value)

      true ->
        remove_nth_item(lms, value)
    end
  end

  defp remove_first_item(%__MODULE__{items: items} = lms, value) do
    next_head_node = items[items[value].next]
    replacement_head_node = %{next_head_node | previous: nil}

    updated_items =
      items
      |> Map.delete(value)
      |> Map.put(replacement_head_node.value, replacement_head_node)

    %{lms | head: replacement_head_node.value, items: updated_items}
  end

  defp remove_last_item(%__MODULE__{items: items} = lms, value) do
    next_tail_node = items[items[value].previous]
    replacement_tail_node = %{next_tail_node | next: nil}

    updated_items =
      items
      |> Map.delete(value)
      |> Map.put(replacement_tail_node.value, replacement_tail_node)

    %{lms | tail: replacement_tail_node.value, items: updated_items}
  end

  defp remove_nth_item(%__MODULE__{items: items} = lms, value) do
    node_to_remove = items[value]
    previous_node = items[node_to_remove.previous]
    next_node = items[node_to_remove.next]
    replacement_previous_node = %{previous_node | next: next_node.value}
    replacement_next_node = %{next_node | previous: previous_node.value}

    updated_items =
      items
      |> Map.delete(node_to_remove.value)
      |> Map.put(previous_node.value, replacement_previous_node)
      |> Map.put(next_node.value, replacement_next_node)

    %{lms | items: updated_items}
  end

  @doc """
  Removes an item from the linked map, or raises if it doesn't exist.

  Returns the updated `LinkedMapSet`, or raises if `value` doesn't exist.

  Behavies the same as `remove/2`, but raises if `value` doesn't exist.

  ## Examples

      iex> LinkedMapSet.new() |> LinkedMapSet.add("a") |> LinkedMapSet.remove!("b")
      ** (LinkedMapSet.MissingValueError) value "b" is not present
  """
  @spec remove!(LinkedMapSet.t(), any) :: LinkedMapSet.t()
  def remove!(linked_map_set, value)

  def remove!(%__MODULE__{items: items} = lms, value) do
    if Map.has_key?(items, value) do
      remove(lms, value)
    else
      raise MissingValueError, value: value
    end
  end

  @doc """
  Returns the number of items in the `linked_map_set`.

  ## Examples

      iex> LinkedMapSet.new() |> LinkedMapSet.add("a") |> LinkedMapSet.size()
      1
  """
  @spec size(LinkedMapSet.t()) :: non_neg_integer
  def size(%__MODULE__{items: items}), do: map_size(items)

  @doc """
  Returns whether the given `value` exists in the given `linked_map_set`.

  ## Examples

      iex> LinkedMapSet.new() |> LinkedMapSet.add("a") |> LinkedMapSet.member?("a")
      true

      iex> LinkedMapSet.new() |> LinkedMapSet.add("a") |> LinkedMapSet.member?("b")
      false
  """
  @spec member?(LinkedMapSet.t(), any) :: boolean
  def member?(%__MODULE__{items: items}, value), do: Map.has_key?(items, value)

  @doc """
  Returns the values as a `List` in order.

  ## Examples

      iex> LinkedMapSet.new() |> LinkedMapSet.add("a") |> LinkedMapSet.add("b") |> LinkedMapSet.to_list()
  """
  @spec to_list(LinkedMapSet.t()) :: [any()]
  def to_list(linked_map_set)

  def to_list(%__MODULE__{head: head, items: items}) do
    case map_size(items) do
      0 -> []
      1 -> [head]
      _ -> [head] ++ remaining_items(head, items)
    end
  end

  defp remaining_items(nil, _items), do: []

  defp remaining_items(current, items) do
    next = items[current].next

    if next == nil do
      []
    else
      [next] ++ remaining_items(next, items)
    end
  end

  defimpl Enumerable do
    def count(linked_map_set) do
      {:ok, LinkedMapSet.size(linked_map_set)}
    end

    def member?(linked_map_set, value) do
      {:ok, LinkedMapSet.member?(linked_map_set, value)}
    end

    # Let the default reduce-based implementation be used since we
    # require traversal of all items to maintain ordering.
    def slice(_linked_map_set), do: {:error, __MODULE__}

    def reduce(linked_map_set, acc, fun) do
      Enumerable.List.reduce(LinkedMapSet.to_list(linked_map_set), acc, fun)
    end
  end
end
