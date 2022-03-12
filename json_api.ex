defmodule JsonAPI do

  def query(cat, id \\ 0, keys \\ [] ) do

    categories = %{
      "posts" => 100,
      "comments" => 500,
      "albums" => 100,
      "photos" => 5000,
      "todos" => 200,
      "users" => 10
    }

    base = "https://jsonplaceholder.typicode.com/"

    cond do
      cat not in Map.keys(categories) ->
        {:error, ~s('#{cat}' is not a valid category.)}

      id > categories[cat] ->
        {:error, ~s(The maximum value of '#{cat}' is #{categories[cat]}.)}

      is_list(keys) and length(keys) > 0 and id > 0 ->
        resp = get_data([base, cat, "/", to_string(id)])
        case resp do
        {:ok, body } ->
          {:ok, get_in(body, keys)}

          _ -> resp
        end

      id > 0 ->
        get_data([base, cat, "/", to_string(id)])

      true ->
        get_data([base, cat])
    end
  end

  defp get_data(url) do
    url
    |> :erlang.iolist_to_binary
    |> HTTPoison.get
    |> handle_response
  end

  defp handle_response( {:ok, %{ status_code: 200, body: body } = _response} ) do
    data = body
           |> Poison.Parser.parse!(%{})
    {:ok, data}
  end

  defp handle_response( {:ok, %{ status_code: code, body: body } = _response} ) do
    message = body
              |> Poison.Parser.parse!(%{})
    {:error, code, message}
  end

  defp handle_response( response ) do
    response
  end
end
