defmodule JsonApi do
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

      is_list(keys) and length(keys) > 0 ->
        url = [base, cat, "/", to_string(id)]
        response = get_data(url)

        case response do
          {:ok, target} ->
            {:ok, get_in(target, keys)}

          _ ->
            response
        end

      id > 0 ->
        url = [base, cat, "/", to_string(id)]
        get_data(url)

      true ->
        url = [base, cat]
        get_data(url)
    end
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    target = Poison.Parser.parse!(body, %{})
    {:ok, target}
  end

  defp handle_response({:ok, %{status_code: status, body: body}}) do
    message =
      body
      |> Poison.Parser.parse!(%{})
      |> get_in(["message"])

    {:error, status, message}
  end

  defp handle_response({:error, reason}), do: {:error, reason}

  defp get_data(url) do
    url
    |> :erlang.iolist_to_binary()
    |> HTTPoison.get()
    |> handle_response()
  end
end
