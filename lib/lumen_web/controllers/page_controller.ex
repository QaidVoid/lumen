defmodule LumenWeb.PageController do
  use LumenWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
