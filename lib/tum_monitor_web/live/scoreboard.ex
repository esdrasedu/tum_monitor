defmodule TumMonitorWeb.ScoreboardLive do
  use Phoenix.LiveView

  import Phoenix.PubSub

  def render(assigns) do
    ~L"""
    <div class="container">
      <p>Change your public key to your name doing:</p>
      <pre><code>Tum.mine("My name is YOUR_NAME)</code></pre>
    </div>

    <div class="container">
      <div class="row">
        <div class="column">
          <%= message(assigns) %>
        </div>
      </div>
    </div>

    <div class="container">
      <div class="row">
        <div class="column column-50">
        <%= monitor(assigns) %>
        </div>
        <div class="column column-50">
          <%= rank(assigns) %>
        </div>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    %{blocks: blocks, rank: rank} = TumMonitor.Scoreboard.state()
    socket = socket
    |> assign(:last_block, blocks |> List.last())
    |> assign(:rank, rank)

    if connected?(socket) do
      :ok = subscribe(TumMonitor.PubSub, "monitor")
    else
      :ok = unsubscribe(TumMonitor.PubSub, "monitor")
    end

    {:ok, socket}
  end

  def handle_info({:update, %{blocks: blocks, rank: rank}}, socket) do
    socket = socket
    |> assign(:last_block, blocks |> List.last())
    |> assign(:rank, rank)

    {:noreply, socket}
  end

  def monitor(%{last_block: last_block} = assigns) when is_map(last_block) do
    ~L"""
    <h2>Monitor</h2>
    <div class="ellipsis">
    <strong>Height:</strong> <span class="highlight"><%= @last_block.height %></span></br>
    <strong>Previous hash:</strong> <span class="highlight"><%= @last_block.previous_hash %></span></br>
    <strong>Hash:</strong> <span class="highlight"><%= @last_block.hash %></span></br>
    <strong>Difficulty:</strong> <span class="highlight"><%= @last_block.difficulty %></span></br>
      <strong>Nounce:</strong> <span class="highlight"><%= @last_block.nounce %></span></br>
      <strong>Public key:</strong> <span class="highlight"><%= @last_block.public_key %></span></br>
      <strong>Signature:</strong> <span class="highlight"><%= @last_block.signature %></span></br>
    </div>
    """
  end
  def monitor(assigns) do
    ~L"""
    <h2>Monitor</h2>
    <p>Waiting connection...</p>
    """
  end

  def rank(%{rank: rank} = assigns) when is_list(rank) do
    ~L"""
    <h2>Rank</h2>
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Points</th>
        </tr>
      </thead>
    <tbody>
    <div class="hide"><%= inspect(rank) %></div>
      <%= for {%{name: name, point: point}, index} <- Enum.with_index(rank) do %>
      <tr>
        <td><div class="ellipsis highlight"><%= name %></div></td>
        <td><span class="highlight"><%= point %></span></td>
      </tr>
      <% end %>
    </tbody>
    </table>
    """
  end
  def rank(assigns) do
    ~L"""
    <h2>Rank</h2>
    <p>Waiting connection...</p>
    """
  end

  def message(%{last_block: last_block} = assigns) when is_map(last_block) do
    ~L"""
    <h2>Last Message</h2>
    <h1 class="highlight"><%= @last_block.message %></h1>
    """
  end
  def message(assigns) do
    ~L"""
    <h2>Last Message</h2>
    <p>Waiting connection...</p>
    """
  end
end
