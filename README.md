# ReqMulti

ReqMulti is a plugin for the [Req](https://github.com/wojtekmach/req) HTTP client library in Elixir. It sends `multipart/form-data` request bodies, built with the [`multipart`](https://hex.pm/packages/multipart) library.

## Installation

Add `req_multi` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:req_multi, "~> 0.1.1"}
  ]
end
```

## Usage

Build a `Multipart` struct, attach the plugin with `ReqMulti.attach/1`, and pass the struct through the `:multi` option:

```elixir
multipart =
  Multipart.new()
  |> Multipart.add_part(Multipart.Part.text_field("hello world", "greeting"))
  |> Multipart.add_part(Multipart.Part.file_field("/path/to/photo.png", "photo"))

Req.new()
|> ReqMulti.attach()
|> Req.post!(multi: multipart)
```

The plugin sets the `Content-Type` (including the multipart boundary) and `Content-Length` headers and streams the encoded body. Without the `:multi` option, the request is sent unchanged.
