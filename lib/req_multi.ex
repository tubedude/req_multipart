defmodule ReqMulti do
  @moduledoc """
  A [Req](https://github.com/wojtekmach/req) plugin to handle multipart upload
  """

  @doc """
  Attach to your Req.Request to start using it.

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
