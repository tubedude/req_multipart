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
end
