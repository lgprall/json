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

    base = "https://jsonplaceholder.typicode.com/"

    cond do
      cat not in Map.keys(categories) ->
        {:error, ~s('#{cat}' is not a valid category.)}

      id > categories[cat] ->
        {:error, ~s(The maximum id for '#{cat}' is #{categories[cat]}.)}

      is_list(keys) and length(keys) > 0 and id > 0 ->
        response = get_data([base, cat, "/", to_string(id)])

        case response do
          {:ok, answer} ->
            {:ok, get_in(answer, keys)}
          _ ->
            response
        end

      id > 0 ->
        get_data([base, cat, "/", to_string(id)])

      true ->
        get_data([base, cat])
    end
  end

  def handle_response({:ok, %{status_code: 200, body: body} = _response}) do
    {:ok, body |> Poison.Parser.parse!(%{})}
  end

  def handle_response({:ok, %{status_code: status, body: body} = _response}) do
    message =
      body
      |> Poison.Parser.parse!(%{})
      |> get_in(["message"])

    {:error, status, message}
  end

  def handle_response({:error, reason}) do
    {:error, reason}
  end

  defp get_data(url) do
    url
    |> :erlang.iolist_to_binary()
    |> HTTPoison.get()
    |> handle_response
  end
end
