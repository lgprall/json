defmodule JsonAPI do
  def query(cat, id \\ 0, keys \\ []) do
    categories = %{
      "posts" => 100,
      "comments" => 500,
      "albums" => 100,
      "photos" => 5000,
      "todos" => 200,
      "users" => 10
    }

    cond do
      cat not in Map.keys(categories) ->
        {:error, ~s('#{cat}' is not a valid category.)}

      id > categories[cat] ->
        {:error, ~s(The maximum id for '#{cat}' is #{categories[cat]}.)}

      true ->
        get_url(cat, id, keys)
    end
  end

  def handle_response(response, keys \\ [])

  def handle_response({:ok, %{status_code: 200, body: body} = _response}, keys) do
    target =
      body
      |> Poison.Parser.parse!(%{})

    if length(keys) > 0 do
      {:ok, target |> get_in(keys)}
    else
      {:ok, target}
    end
  end

  def handle_response({:ok, %{status_code: status, body: body} = _response}, _keys) do
    message =
      body
      |> Poison.Parser.parse!(%{})
      |> get_in(["message"])

    {:error, status, message}
  end

  def handle_response({:error, reason}, _) do
    {:error, reason}
  end

  defp get_url(cat, id, keys) do
    base = "https://jsonplaceholder.typicode.com/"

    cond do
      is_list(keys) and length(keys) > 0 ->
        [base, cat, "/", to_string(id)]
        |> :erlang.iolist_to_binary()
        |> HTTPoison.get()
        |> handle_response(keys)

      id > 0 ->
        [base, cat, "/", to_string(id)]
        |> :erlang.iolist_to_binary()
        |> HTTPoison.get()
        |> handle_response

      true ->
        [base, cat]
        |> :erlang.iolist_to_binary()
        |> HTTPoison.get()
        |> handle_response
    end
  end
end
