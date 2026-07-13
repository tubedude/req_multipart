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

## Building the multipart

The `%Multipart{}` struct comes from the [`multipart`](https://hexdocs.pm/multipart) library. Start with `Multipart.new/0` and pipe in one part per field or attachment with `Multipart.add_part/2`. Each part is built with a helper from [`Multipart.Part`](https://hexdocs.pm/multipart/Multipart.Part.html):

```elixir
multipart =
  Multipart.new()
  # a plain form field
  |> Multipart.add_part(Multipart.Part.text_field("hello world", "greeting"))
  # a file read from disk (filename and content-type are inferred from the path)
  |> Multipart.add_part(Multipart.Part.file_field("/path/to/photo.png", "photo"))
  # a file whose contents you already have in memory
  |> Multipart.add_part(
    Multipart.Part.file_content_field("report.pdf", pdf_binary, "document")
  )
```

Common `Multipart.Part` builders:

| Helper | Use for |
| --- | --- |
| `text_field(value, name)` | a simple form field |
| `file_field(path, name)` | a file read from disk |
| `file_content_field(filename, content, name)` | a file whose bytes you already hold |
| `stream_field(stream, name)` | a field streamed from an enumerable |

See the [`Multipart.Part` docs](https://hexdocs.pm/multipart/Multipart.Part.html) for the full list and for the optional `headers`/`opts` arguments (e.g. a custom content type).
