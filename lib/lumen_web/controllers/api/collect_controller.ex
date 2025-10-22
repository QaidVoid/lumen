defmodule LumenWeb.Api.CollectController do
  use LumenWeb, :controller
  alias Lumen.Analytics

  def options(conn, _params) do
    conn
    |> send_resp(:no_content, "")
  end

  @doc """
  Endpoint to collect analytics events.

  Expected JSON payload:
  {
    "site_id": "FdX0i0Us",
    "path": "/about",
    "referrer": "https://elixir-lang.org",
  }
  """
  def create(conn, params) do
    with {:ok, site_id} <- validate_site(params["site_id"]),
         {:ok, _event} <- create_event(site_id, params, conn) do
      # Return a 202 Accepted (async processing)
      conn
      |> put_status(:accepted)
      |> json(%{status: "ok"})
    else
      {:error, :invalid_site} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid site_id"})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Invalid event data", details: translate_errors(changeset)})
    end
  end

  defp validate_site(nil), do: {:error, :invalid_site}

  defp validate_site(public_id) do
    case Analytics.get_site_by_public_id(public_id) do
      nil -> {:error, :invalid_site}
      site -> {:ok, site.id}
    end
  end

  defp create_event(site_id, params, conn) do
    ip = get_ip_address(conn)
    user_agent = get_user_agent(conn)

    attrs = %{
      site_id: site_id,
      path: params["path"] || "/",
      referrer: params["referrer"],
      ip: ip,
      user_agent: user_agent
    }

    Analytics.track_event(attrs)
  end

  defp get_ip_address(conn) do
    case get_req_header(conn, "x-forwarded-for") do
      [ip | _] -> ip |> String.split(",") |> List.first() |> String.trim()
      [] -> to_string(:inet_parse.ntoa(conn.remote_ip))
    end
  end

  defp get_user_agent(conn) do
    case get_req_header(conn, "user-agent") do
      [user_agent | _] -> user_agent
      [] -> ""
    end
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
