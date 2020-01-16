defmodule Deadend.Plug do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    {:ok, content} = File.read(Path.join([:code.priv_dir(:deadend), "404.html"]))

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(404, content)
  end
end
