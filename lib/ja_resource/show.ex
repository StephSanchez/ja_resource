defmodule JaResource.Show do
  import Plug.Conn

  @moduledoc """
  Defines a behaviour for displaying a resource and the function to execute it.

  It relies on (and uses):

    * JaResource.Record
    * JaResource.Serializable

  When used JaResource.Show defines the `show/2` action suitable for handling
  json-api requests.

  To customize the behaviour of the show action the following callbacks can be implemented:

    * handle_show/2
    * render_index/2
    * JaResource.Record.record/2
    * JaResource.Record.records/1

  """

  @doc """
  Returns the model to be represented by this resource.

  Default implementation is the result of the JaResource.Record.record/2
  callback.

  `handle_show/2` can return nil to send a 404, a conn with any response/body,
  or a record to be serialized.

  Example custom implementation:

      def handle_show(conn, id) do
        Repo.get_by(Post, slug: id)
      end

  In most cases JaResource.Record.record/2 and JaResource.Records.records/1 are
  the better customization hooks.
  """
  @callback handle_show(Plug.Conn.t(), JaResource.id()) :: Plug.Conn.t() | JaResource.record()

  @doc """
  Returns a `Plug.Conn` in response to successful show.

  Default implementation renders the view.
  """
  @callback render_show(Plug.Conn.t(), JaResource.record()) :: Plug.Conn.t()

  defmacro __using__(_) do
    quote do
      use JaResource.Record
      use JaResource.Serializable
      @behaviour JaResource.Show

      def handle_show(conn, id), do: record(conn, id)

      def render_show(conn, model) do
        conn
        |> Phoenix.Controller.render(:show, data: model)
      end

      defoverridable handle_show: 2, render_show: 2
    end
  end

  @doc """
  Execute the show action on a given module implementing Show behaviour and conn.
  """
  def call(controller, conn) do
    conn
    |> controller.handle_show(conn.params["id"])
    |> JaResource.Show.respond(conn, controller)
  end

  @doc false
  def respond(%Plug.Conn{} = conn, _old_conn, _controller), do: conn

  def respond(nil, conn, _controller) do
    conn
    |> put_status(:not_found)
    |> Phoenix.Controller.render(:errors,
      data: %{status: 404, title: "Not Found", detail: "The resource was not found"}
    )
  end

  def respond(model, conn, controller) do
    opts = controller.serialization_opts(conn, conn.query_params, model)
    controller.render_index(conn, model, opts)
  end
end
