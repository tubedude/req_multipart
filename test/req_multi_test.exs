defmodule ReqMultiTest do
  use ExUnit.Case

  doctest ReqMulti

  setup do
    req =
      Req.new(plug: {Req.Test, ReqMulti.Stub})
      |> ReqMulti.attach()

    {:ok, req: req}
  end

  test "allows for multi option", %{req: req} do
    #  Otherwise it raises argument error
    Req.Test.stub(ReqMulti.Stub, fn conn ->
      Req.Test.text(conn, "ok")
    end)

    req = Req.merge(req, multi: :test)
    assert %Req.Request{} = req

    assert_raise(
      ArgumentError,
      "Option `:multi` expects a `%Multipart{}` struct, got `:test`.",
      fn -> Req.get(req) end
    )
  end

  test "Requires a Multipart in multi", %{req: req} do
    Req.Test.stub(ReqMulti.Stub, fn conn ->
      assert {"content-type", content_type} = List.keyfind(conn.req_headers, "content-type", 0)
      assert String.starts_with?(content_type, "multipart/form-data")
      assert String.contains?(content_type, "boundary=")

      Req.Test.text(conn, "ok")
    end)

    req =
      req
      |> Req.merge(multi: Multipart.new())

    assert {:ok, %Req.Response{}} = Req.put(req)
  end

  test "regular request is unchanged", %{req: req} do
    Req.Test.stub(ReqMulti.Stub, fn conn ->
      Req.Test.text(conn, "ok")
    end)

    assert {:ok, %Req.Response{}} = Req.put(req)
  end

  test "sends parts that the server can parse as multipart form data", %{req: req} do
    multipart =
      Multipart.new()
      |> Multipart.add_part(Multipart.Part.text_field("hello world", "greeting"))
      |> Multipart.add_part(Multipart.Part.text_field("42", "answer"))

    Req.Test.stub(ReqMulti.Stub, fn conn ->
      # Plug must be able to parse the quoted boundary the plugin sends,
      # and the declared parts must round-trip to params on the server side.
      conn =
        Plug.Parsers.call(
          conn,
          Plug.Parsers.init(parsers: [:multipart], pass: ["*/*"])
        )

      assert conn.body_params["greeting"] == "hello world"
      assert conn.body_params["answer"] == "42"

      Req.Test.text(conn, "ok")
    end)

    assert {:ok, %Req.Response{status: 200}} = Req.post(Req.merge(req, multi: multipart))
  end

  test "sets a Content-Length header matching the multipart body", %{req: req} do
    multipart =
      Multipart.new()
      |> Multipart.add_part(Multipart.Part.text_field("hello world", "greeting"))

    expected_length = Multipart.content_length(multipart)

    Req.Test.stub(ReqMulti.Stub, fn conn ->
      assert {"content-length", value} = List.keyfind(conn.req_headers, "content-length", 0)
      assert value == to_string(expected_length)

      Req.Test.text(conn, "ok")
    end)

    assert {:ok, %Req.Response{}} = Req.post(Req.merge(req, multi: multipart))
  end

  test "multipart replaces any pre-existing :body", %{req: req} do
    multipart =
      Multipart.new()
      |> Multipart.add_part(Multipart.Part.text_field("from multipart", "field"))

    Req.Test.stub(ReqMulti.Stub, fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)

      # The plain body set via :body must be dropped in favor of the stream.
      refute body == "should be discarded"
      assert String.contains?(body, "from multipart")

      content_type = List.keyfind(conn.req_headers, "content-type", 0) |> elem(1)
      assert String.starts_with?(content_type, "multipart/form-data")

      Req.Test.text(conn, "ok")
    end)

    req = Req.merge(req, body: "should be discarded", multi: multipart)
    assert {:ok, %Req.Response{}} = Req.post(req)
  end

  test "multi: nil raises, same as any other non-Multipart value", %{req: req} do
    # Documents current behavior: nil is not treated as "no multipart".
    # If lenient nil handling is ever desired, that is a source change.
    Req.Test.stub(ReqMulti.Stub, fn conn -> Req.Test.text(conn, "ok") end)

    assert_raise(
      ArgumentError,
      "Option `:multi` expects a `%Multipart{}` struct, got `nil`.",
      fn -> Req.get(Req.merge(req, multi: nil)) end
    )
  end

  test "attach/2 is idempotent — attaching twice sends one well-formed request" do
    multipart =
      Multipart.new()
      |> Multipart.add_part(Multipart.Part.text_field("v", "k"))

    req =
      Req.new(plug: {Req.Test, ReqMulti.Stub})
      |> ReqMulti.attach()
      |> ReqMulti.attach()

    Req.Test.stub(ReqMulti.Stub, fn conn ->
      # Exactly one Content-Type / Content-Length pair, not duplicated.
      content_types = for {"content-type", v} <- conn.req_headers, do: v
      assert length(content_types) == 1
      assert String.starts_with?(hd(content_types), "multipart/form-data")

      conn =
        Plug.Parsers.call(conn, Plug.Parsers.init(parsers: [:multipart], pass: ["*/*"]))

      assert conn.body_params["k"] == "v"

      Req.Test.text(conn, "ok")
    end)

    assert {:ok, %Req.Response{}} = Req.post(Req.merge(req, multi: multipart))
  end
end
