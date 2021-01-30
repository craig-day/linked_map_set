# LinkedMapSet

A `LinkedMapSet` is an extension to [`MapSet`](https://hexdocs.pm/elixir/MapSet.html)
that maintains ordering.

It does this by keeping pointers to previous and next elements based on insert
order.

I built this to have a collection I can traverse in either direction, but also
be able to remove items in less-than-linear time. I also didn't want something
that needed to be sorted or rebalanced after each addition or removal.

This uses [`Map`](https://hexdocs.pm/elixir/Map.html) underneath, much like
[`MapSet`](https://hexdocs.pm/elixir/MapSet.html), so removing arbitrary items
can happen in logarithmic time, rather than linear time that most sorted
collections incur.

## Installation

```elixir
def deps do
  [
    {:linked_map_set, "~> 0.1.0"}
  ]
end
```

## Usage

See the [documentation](https://hexdocs.pm/linked_map_set) for API reference and examples.
