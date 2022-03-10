defmodule JsonTest do
  use ExUnit.Case
#  doctest JsonTest

  test "rejects invalid categories" do
    response = JsonAPI.query("zork")

    assert response == {:error, "'zork' is not a valid category."}
  end
  
  test "rejects out of bounds id" do
    response = JsonAPI.query("posts",101)

    assert response == {:error, "The maximum value of 'posts' is 100."}
  end

  test "reports correct data for cat/id" do
    response = JsonAPI.query("posts",1)

    assert response == {:ok,
	   %{
		 "body" => "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto",
		 "id" => 1,
		 "title" => "sunt aut facere repellat provident occaecati excepturi optio reprehenderit", 
		 "userId" => 1
	   }}
  end

  test "reports correct data for single key" do
    response = JsonAPI.query("users",10,["address"])

    assert response ==  {:ok,
 %{
   "city" => "Lebsackbury",
   "geo" => %{"lat" => "-38.2386", "lng" => "57.2232"},
   "street" => "Kattie Turnpike",
   "suite" => "Suite 198",
   "zipcode" => "31428-2261"
 }}
  end
  test "reports correct data for multiple key" do
	response = JsonAPI.query("users",10,["address","geo"])

	assert response == {:ok, %{"lat" => "-38.2386", "lng" => "57.2232"}}
  end

end
