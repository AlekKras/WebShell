defmodule WebShell do
  require Logger
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    web_port = WebShell.Config.web_port
    sink_port = WebShell.Config.sink_port

    children = [
      supervisor(Task.Supervisor, [[name: WebShell.TaskSupervisor]]),
      Plug.Adapters.Cowboy.child_spec(:http, WebShell.Web, [], [port: web_port]),
      worker(WebShell.Plumber, []),
      worker(Task, [WebShell.Sink, :listen, [sink_port]])
    ]

    Logger.info "Starting WebShell web: #{WebShell.Config.base_url}"
    if WebShell.Config.show_listing() do
      Logger.info "exposing /pipes"
    end


    opts = [strategy: :one_for_one, name: WebShell.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
