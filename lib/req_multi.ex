defmodule ReqMulti do
  @moduledoc """
  A [Req](https://github.com/wojtekmach/req) plugin for sending
  `multipart/form-data` request bodies.

  It builds on the [`multipart`](https://hex.pm/packages/multipart) library:
  you assemble a `Multipart` struct and hand it to Req through the `:multi`
  option. The plugin then sets the `Content-Type` (with the multipart
  boundary) and `Content-Length` headers and streams the encoded body.

  ## Usage

      multipart =
        Multipart.new()
        |> Multipart.add_part(Multipart.Part.text_field("hello world", "greeting"))

      Req.new()
      |> ReqMulti.attach()
      |> Req.post!(multi: multipart)

  ## Building the multipart

  The `%Multipart{}` struct comes from the
  [`multipart`](https://hexdocs.pm/multipart) library. Start with
  `Multipart.new/0` and add one part per field or attachment with
  `Multipart.add_part/2`, using a builder from `Multipart.Part`:

      Multipart.new()
      # a plain form field
      |> Multipart.add_part(Multipart.Part.text_field("hello world", "greeting"))
      # a file read from disk
      |> Multipart.add_part(Multipart.Part.file_field("/path/to/photo.png", "photo"))
      # a file whose bytes you already hold
      |> Multipart.add_part(Multipart.Part.file_content_field("report.pdf", pdf, "document"))

  Other common builders are `Multipart.Part.stream_field/3` and the
  lower-level `binary_body/2`/`file_body/2`. See the
  [`Multipart.Part`](https://hexdocs.pm/multipart/Multipart.Part.html) docs
  for the full list and their optional `headers`/`opts` arguments.

  ## Options

    * `:multi` - a `%Multipart{}` struct to encode and send as the request
      body. When set to any other value, the request raises an
      `ArgumentError`. When omitted, the request is sent unchanged.

  """

  @doc """
  Attaches the plugin to a `Req.Request`, registering the `:multi` option.

  Call once when building your request. See the module documentation for the
  `:multi` option and a full example.

  ## Examples

      iex> Req.new() |> ReqMulti.attach()


  """
  @spec attach(req :: Req.Request.t()) :: Req.Request.t()
  def attach(req) do
    req
    |> Req.Request.register_options([:multi])
    |> Req.Request.prepend_request_steps(multipart_body: &multipart_body_step/1)
  end

  defp multipart_body_step(req) do
    case Req.Request.get_option(req, :multi, :notfound) do
      :notfound ->
        req

      %Multipart{} = multipart ->
        process_multipart(req, multipart)

      value ->
        raise ArgumentError,
          message: "Option `:multi` expects a `%Multipart{}` struct, got `#{inspect(value)}`."
    end
  end

  defp process_multipart(req, multipart) do
    headers = [
      {"Content-Type", Multipart.content_type(multipart, "multipart/form-data")},
      {"Content-Length", to_string(Multipart.content_length(multipart))}
    ]

    req
    |> Req.Request.put_headers(headers)
    |> Req.Request.delete_option(:body)
    |> Req.merge(body: Multipart.body_stream(multipart))
  end
end
