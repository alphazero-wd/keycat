defmodule KeycatWeb.PageController do
  use KeycatWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
