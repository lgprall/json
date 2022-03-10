defmodule JsonAPI do
  @c %{"posts"=>100,"comments"=>500,"albums"=>100,"photos"=>5000,"todos"=>200,"users"=>10}
  @b "https://jsonplaceholder.typicode.com/"

  def query(c, id \\ 0, keys \\ []),       do: chk_input(c, id) |> request({c, id, keys})

  defp chk_input(c, id) ,                  do: is_cat(c in Map.keys(@c), c, id)

  defp is_cat(true, c, id),                do: in_range(id <= @c[c], c)
  defp is_cat(_,    c, _ ),                do: {:error, "'#{c}' is invalid"}

  defp in_range(true, _ ),                 do: :ok
  defp in_range( _  , c ),                 do: {:error, "'#{c}' max id: #{@c[c]}"}

  defp request(:ok, {c, id, keys}),        do: lookup(c, id) |> reply(keys)
  defp request({:error, msg},  _   ),      do: msg

  defp lookup(c, 0),                       do: HTTPoison.get("#{@b}#{c}")
  defp lookup(c, i),                       do: HTTPoison.get("#{@b}#{c}/#{to_string(i)}")

  defp reply({:error, reason }, _ ),              do: {:error,    reason}
  defp reply({_,%{status_code: 200,body: b}},[]), do: {:ok,       parse(b) }
  defp reply({_,%{status_code: 200,body: b}},k),  do: {:ok,       parse(b) |> get_in(k) }
  defp reply({_,%{status_code:  s, body: b}},_),  do: {:error, s, parse(b) |> get_in(["message"])}

  defp parse(body),                        do: Poison.Parser.parse!(body, %{})

  end
