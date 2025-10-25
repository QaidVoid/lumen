defmodule LumenWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use LumenWeb, :html

  embed_templates "page_html/*"

  def feature_card(assigns) do
    ~H"""
    <div class="relative rounded-2xl border border-base-300 p-8 hover:shadow-lg transition bg-base-100">
      <div class={"flex items-center justify-center w-12 h-12 rounded-lg mb-4 #{@icon_bg}"}>
        <.icon name={@icon} class={"w-6 h-6 #{@icon_color}"} />
      </div>
      <h3 class="text-lg font-semibold text-base-content mb-2">{@title}</h3>
      <p class="text-base-content/70">{@desc}</p>
    </div>
    """
  end

  def step_card(assigns) do
    ~H"""
    <div class="flex flex-col">
      <dt class="flex items-center gap-x-3 text-lg font-semibold leading-7 text-base-content">
        <div class="flex h-10 w-10 items-center justify-center rounded-lg bg-primary text-base-100 font-bold">
          {@number}
        </div>
        {@title}
      </dt>
      <dd class="mt-4 flex flex-auto flex-col text-base leading-7 text-base-content/70">
        <p class="flex-auto">{@desc}</p>
      </dd>
    </div>
    """
  end
end
