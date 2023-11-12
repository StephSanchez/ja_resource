defmodule JaResource.ShowTest do
  use ExUnit.Case
  use Plug.Test
  alias JaResource.Show

  defmodule DefaultController do
    use Phoenix.Controller
    use JaResource.Show
    def repo, do: JaResourceTest.Repo
    def model, do: JaResourceTest.Post
  end

  defmodule CustomController do
    use Phoenix.Controller
    use JaResource.Show
    def repo, do: JaResourceTest.Repo
    def handle_show(conn, _id), do: send_resp(conn, 401, "")

    def render_show(conn, model),
      do: put_status(conn, :created) |> Phoenix.Controller.render(:show, data: model)
  end

  test "default implementation return 404 if not found" do
    conn = prep_conn(:get, "/posts/404", %{"id" => 404})
    response = Show.call(DefaultController, conn)
    assert response.status == 404
    {:ok, body} = Jason.decode(response.resp_body)

    assert body == %{
             "action" => "errors.json",
             "errors" => %{
               "detail" => "The resource was not found",
               "status" => 404,
               "title" => "Not Found"
             }
           }
  end
  @tag :skip # due to an error with the test repo. Currently, the repository is unable to retrieve the identifier of the resource even though it is present in the repository.
  test "default implementation return 200 if found" do
    {:ok, post} = JaResourceTest.Repo.insert(%JaResourceTest.Post{id: 200})
    conn = prep_conn(:get, "/posts/#{post.id}", %{"id" => post.id})
    response = Show.call(DefaultController, conn)
    assert response.status == 200
  end

  test "custom implementation return 401" do
    conn = prep_conn(:get, "/posts/401", %{"id" => 401})
    response = Show.call(CustomController, conn)
    assert response.status == 401
  end

  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})

    conn(method, path, params)
    |> fetch_query_params
    |> Phoenix.Controller.put_view(JaResourceTest.PostView)
  end
end
