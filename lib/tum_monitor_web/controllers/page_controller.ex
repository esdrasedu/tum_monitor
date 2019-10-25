defmodule TumMonitorWeb.PageController do
  use TumMonitorWeb, :controller

  def index(conn, _params) do
    conn
    |> Phoenix.Controller.redirect(to: "/scoreboard")
    |> halt()
  end
end
