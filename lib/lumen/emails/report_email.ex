defmodule Lumen.Emails.ReportEmail do
  import Swoosh.Email
  alias Lumen.Analytics

  def weekly_report(site, user) do
    stats = Analytics.get_site_stats(site.id, 7)
    top_pages = Analytics.get_top_pages(site.id, limit: 5)
    top_referrers = Analytics.get_top_referrers(site.id, limit: 5)

    new()
    |> to({user.email, user.email})
    |> from({"Lumen Analytics", "reports@lumen-analytics.com"})
    |> subject("Weekly Analytics Report for #{site.name}")
    |> html_body(build_html_body(site, stats, top_pages, top_referrers))
    |> text_body(build_text_body(site, stats, top_pages, top_referrers))
  end

  # TODO: this is a mess, figure out how to refactor this
  # not sure how to do this since it's not a Web component
  #
  # I'd atleast want to get rid of the custom css
  # and just use tailwind classes and use hero icons
  # without having to copy the svg
  defp build_html_body(site, stats, top_pages, top_referrers) do
    """
    <!DOCTYPE html>
    <html>
      <head>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 10px; text-align: center; }
          .stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; margin: 20px 0; }
          .stat-card { background: #f7fafc; padding: 20px; border-radius: 8px; text-align: center; }
          .stat-value { font-size: 32px; font-weight: bold; color: #2d3748; }
          .stat-label { font-size: 14px; color: #718096; margin-top: 5px; }
          .section { margin: 30px 0; }
          .section-title { font-size: 18px; font-weight: bold; margin-bottom: 15px; color: #2d3748; display: flex; align-items: center; }
          .list-item { padding: 10px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; }
          .list-item:last-child { border-bottom: none; }
          .footer { text-align: center; margin-top: 40px; padding-top: 20px; border-top: 1px solid #e2e8f0; color: #718096; font-size: 14px; }
          .button { display: inline-block; background: #667eea; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; margin-top: 20px; }
          .size-6 { width: 1.5rem; height: 1.5rem; }
          .size-10 { width: 2.5rem; height: 2.5rem; }
          .centered { display: flex; align-items: center; justify-content: center; }
        </style>
      </head>
      <body>
        <div class="header">
          <h1 class="centered">
          <!-- hero-chart-bar -->
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-10">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 0 1 3 19.875v-6.75ZM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V8.625ZM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V4.125Z" />
          </svg>

          Weekly Report</h1>
          <p style="margin: 10px 0 0 0; opacity: 0.9;">#{site.name}</p>
          <p style="margin: 5px 0 0 0; font-size: 14px; opacity: 0.8;">#{site.domain}</p>
        </div>
        <div class="stats">
          <div class="stat-card">
            <div class="stat-value">#{stats.total_views}</div>
            <div class="stat-label">Total Views</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">#{stats.unique_visitors}</div>
            <div class="stat-label">Unique Visitors</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">#{stats.avg_views_per_day}</div>
            <div class="stat-label">Avg. Views/Day</div>
          </div>
        </div>

        <div class="section">
          <div class="section-title">
          <!-- hero-document-text -->
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
          </svg>

          Top Pages</div>
          <div style="background: white; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;">
            #{render_top_pages(top_pages)}
          </div>
        </div>

        <div class="section">
          <div class="section-title">
          <!-- hero-globe-alt -->
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 21a9.004 9.004 0 0 0 8.716-6.747M12 21a9.004 9.004 0 0 1-8.716-6.747M12 21c2.485 0 4.5-4.03 4.5-9S14.485 3 12 3m0 18c-2.485 0-4.5-4.03-4.5-9S9.515 3 12 3m0 0a8.997 8.997 0 0 1 7.843 4.582M12 3a8.997 8.997 0 0 0-7.843 4.582m15.686 0A11.953 11.953 0 0 1 12 10.5c-2.998 0-5.74-1.1-7.843-2.918m15.686 0A8.959 8.959 0 0 1 21 12c0 .778-.099 1.533-.284 2.253m0 0A17.919 17.919 0 0 1 12 16.5c-3.162 0-6.133-.815-8.716-2.247m0 0A9.015 9.015 0 0 1 3 12c0-1.605.42-3.113 1.157-4.418" />
          </svg>

          Top Referrers</div>
          <div style="background: white; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;">
            #{render_top_referrers(top_referrers)}
          </div>
        </div>

        <div style="text-align: center; margin-top: 30px;">
          <a href="#{LumenWeb.Endpoint.url()}/dashboard/#{site.id}" class="button">
            View Full Dashboard →
          </a>
        </div>

        <div class="footer">
          <p>Powered by <strong>Lumen Analytics</strong></p>
          <p style="margin-top: 10px; font-size: 12px;">
            <a href="#{LumenWeb.Endpoint.url()}/sites" style="color: #667eea;">Manage Settings</a>
          </p>
        </div>
      </body>
    </html>
    """
  end

  defp render_top_pages([]), do: "<div class='list-item'>No data yet</div>"

  defp render_top_pages(pages) do
    Enum.map_join(pages, fn {path, count} ->
      """
      <div class="list-item">
      <span style="font-family: monospace; font-size: 14px;">#{path}</span>
      <span style="font-weight: bold;">#{count} views</span>
      </div>
      """
    end)
  end

  defp render_top_referrers([]), do: "<div class='list-item'>No referrer data yet</div>"

  defp render_top_referrers(referrers) do
    Enum.map_join(referrers, fn {referrer, count, _percentage} ->
      clean_referrer =
        referrer
        |> String.replace(~r/^https?:\/\//, "")
        |> String.replace(~r/^www\./, "")

      """
      <div class="list-item">
        <span style="font-size: 14px;">#{clean_referrer}</span>
        <span style="font-weight: bold;">#{count} visits</span>
      </div>
      """
    end)
  end

  defp build_text_body(site, stats, top_pages, top_referrers) do
    """
    Weekly Analytics Report for #{site.name}
    #{site.domain}
    === STATS (Last 7 Days) ===
    Total Views: #{stats.total_views}
    Unique Visitors: #{stats.unique_visitors}
    Avg. Views/Day: #{stats.avg_views_per_day}

    === TOP PAGES ===
    #{render_text_pages(top_pages)}

    === TOP REFERRERS ===
    #{render_text_referrers(top_referrers)}

    View full dashboard: #{LumenWeb.Endpoint.url()}/dashboard/#{site.id}

    ---
    Powered by Lumen Analytics
    Manage settings: #{LumenWeb.Endpoint.url()}/sites
    """
  end

  defp render_text_pages([]), do: "No data yet"

  defp render_text_pages(pages) do
    Enum.map_join(pages, "\n", fn {path, count} ->
      "  #{path} - #{count} views"
    end)
  end

  defp render_text_referrers([]), do: "No referrer data yet"

  defp render_text_referrers(referrers) do
    Enum.map_join(referrers, "\n", fn {referrer, count, _percentage} ->
      "  #{referrer} - #{count} visits"
    end)
  end
end
