# ReqMulti

ReqMulti is a plugin for the [Req](https://github.com/wojtekmach/req) HTTP client library in Elixir. It allows you to add Multipart to your requests.

## Installation

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
