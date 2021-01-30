defmodule LinkedMapSetTest do
  use ExUnit.Case
  alias LinkedMapSet.Node
  doctest LinkedMapSet

  test "new/0" do
    assert LinkedMapSet.new() == %LinkedMapSet{head: nil, tail: nil, items: %{}}
  end

  test "add/2 with an empty set" do
    result = LinkedMapSet.new() |> LinkedMapSet.add("a")

    assert result.head == "a"
    assert result.tail == "a"
    assert Map.keys(result.items) == ["a"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == nil
  end

  test "add/2 with a single item set" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("a")
    result = set |> LinkedMapSet.add("b")

    assert result.head == "a"
    assert result.tail == "b"
    assert Map.keys(result.items) == ["a", "b"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == "b"
    assert result.items["b"].previous == "a"
    assert result.items["b"].next == nil
  end

  test "add/2 with a N item set" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("a") |> LinkedMapSet.add("b")
    result = set |> LinkedMapSet.add("c")

    assert result.head == "a"
    assert result.tail == "c"
    assert Map.keys(result.items) == ["a", "b", "c"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == "b"
    assert result.items["b"].previous == "a"
    assert result.items["b"].next == "c"
    assert result.items["c"].previous == "b"
    assert result.items["c"].next == nil
  end

  test "add/2 with an existing value to a single item set" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("a")
    result = set |> LinkedMapSet.add("a")

    assert result.head == "a"
    assert result.tail == "a"
    assert Map.keys(result.items) == ["a"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == nil
  end

  test "add/2 with an existing value to a N item set" do
    set =
      LinkedMapSet.new()
      |> LinkedMapSet.add("a")
      |> LinkedMapSet.add("b")
      |> LinkedMapSet.add("c")

    result = set |> LinkedMapSet.add("b")

    assert result.head == "a"
    assert result.tail == "b"
    assert Map.keys(result.items) == ["a", "b", "c"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == "c"
    assert result.items["c"].previous == "a"
    assert result.items["c"].next == "b"
    assert result.items["b"].previous == "c"
    assert result.items["b"].next == nil
  end

  test "add_new/2 with a new item" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("a")
    result = set |> LinkedMapSet.add_new("b")

    assert Map.keys(result.items) == ["a", "b"]
  end

  test "add_new/2 with an existing item" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("a")
    result = set |> LinkedMapSet.add_new("a")

    assert Map.keys(result.items) == ["a"]
  end

  test "add_new!/2 with a new item" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("a")
    result = set |> LinkedMapSet.add_new!("b")

    assert Map.keys(result.items) == ["a", "b"]
  end

  test "add_new!/2 with an existing item" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("a")
    message = ~s(value "a" is already present)

    assert_raise LinkedMapSet.DuplicateValueError, message, fn ->
      LinkedMapSet.add_new!(set, "a")
    end
  end

  test "remove/2 with an empty set" do
    set = LinkedMapSet.new()
    result = set |> LinkedMapSet.remove("foo")

    assert result == set
  end

  test "remove/2 with a non-existent item" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("a")
    result = set |> LinkedMapSet.remove("foo")

    assert result == set
  end

  test "remove/2 with the only item" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("a")
    result = set |> LinkedMapSet.remove("a")

    assert result == LinkedMapSet.new()
  end

  test "remove/2 with the first of two items" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("a") |> LinkedMapSet.add("b")
    result = set |> LinkedMapSet.remove("a")

    assert result.head == "b"
    assert result.tail == "b"
    assert Map.keys(result.items) == ["b"]
    assert result.items["b"].previous == nil
    assert result.items["b"].next == nil
  end

  test "remove/2 with the last of two items" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("a") |> LinkedMapSet.add("b")
    result = set |> LinkedMapSet.remove("b")

    assert result.head == "a"
    assert result.tail == "a"
    assert Map.keys(result.items) == ["a"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == nil
  end

  test "remove/2 with the first of N items" do
    set =
      LinkedMapSet.new()
      |> LinkedMapSet.add("a")
      |> LinkedMapSet.add("b")
      |> LinkedMapSet.add("c")

    result = set |> LinkedMapSet.remove("a")

    assert result.head == "b"
    assert result.tail == "c"
    assert Map.keys(result.items) == ["b", "c"]
    assert result.items["b"].previous == nil
    assert result.items["b"].next == "c"
    assert result.items["c"].previous == "b"
    assert result.items["c"].next == nil
  end

  test "remove/2 with the last of N items" do
    set =
      LinkedMapSet.new()
      |> LinkedMapSet.add("a")
      |> LinkedMapSet.add("b")
      |> LinkedMapSet.add("c")

    result = set |> LinkedMapSet.remove("c")

    assert result.head == "a"
    assert result.tail == "b"
    assert Map.keys(result.items) == ["a", "b"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == "b"
    assert result.items["b"].previous == "a"
    assert result.items["b"].next == nil
  end

  test "remove/2 from the middle of N items" do
    set =
      LinkedMapSet.new()
      |> LinkedMapSet.add("a")
      |> LinkedMapSet.add("b")
      |> LinkedMapSet.add("c")

    result = set |> LinkedMapSet.remove("b")

    assert result.head == "a"
    assert result.tail == "c"
    assert Map.keys(result.items) == ["a", "c"]
    assert result.items["a"].previous == nil
    assert result.items["a"].next == "c"
    assert result.items["c"].previous == "a"
    assert result.items["c"].next == nil
  end

  test "remove!/2 with an existing item" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("a")
    result = set |> LinkedMapSet.remove!("a")

    assert Map.keys(result.items) == []
  end

  test "remove!/2 with a non-existant item" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("a")
    message = ~s(value "b" is not present)

    assert_raise LinkedMapSet.MissingValueError, message, fn ->
      LinkedMapSet.remove!(set, "b")
    end
  end

  test "size/1" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("a")

    assert LinkedMapSet.size(set) == 1
  end

  test "member?/2" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("a")

    assert LinkedMapSet.member?(set, "a") == true
    assert LinkedMapSet.member?(set, "b") == false
  end

  test "to_list/1" do
    set = LinkedMapSet.new() |> LinkedMapSet.add("b") |> LinkedMapSet.add("a")

    assert LinkedMapSet.to_list(set) == ["b", "a"]
  end
end
