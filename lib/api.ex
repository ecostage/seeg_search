defmodule Api do
  def init(default_opts) do
    IO.puts "Starting API..."
    default_opts
  end

  def call(conn, _opts) do
    conn = Plug.Conn.fetch_query_params(conn)
    database = Index.load_db("database.exs")
    index = Index.create(database, DefaultTokenizer)

    conn.query_params
    |> Map.get("q", "")
    |> SeegSearch.search(index)
    |> JSON.encode
    |> case do
      {:ok, body} ->
        conn
        |> Plug.Conn.put_resp_header("Content-Type", "application/json; charset=utf-8")
        |> Plug.Conn.send_resp(200, body)
      {:error, reason} ->
        conn |> Plug.Conn.send_resp(500, "")
    end
  end
end
