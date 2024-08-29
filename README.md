# ReqMulti

**TODO: Add description**

ReqMulti is a plugin for the [Req](https://github.com/wojtekmach/req) HTTP client library in Elixir. It allows you to add Multipart to your requests.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `req_multi` to your list of dependencies in `mix.exs`:
Add `req_multi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:req_multi, "~> 0.1.0"}
  ]
end
```

Attach to your Req:

```elixir

multipart = Multipart.new() |> Multipart.add_part( ... )

req = 
  Req.new()
  |> ReqMulti.attach()
  |> Req.merge(multi: multipart)

```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/req_multi>.




