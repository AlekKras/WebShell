defmodule WebShell.Sink do
  require Logger

  def listen(port) do
    {:ok, addr} = WebShell.Config.sink_bind
    |> String.to_charlist()
    |> :inet_parse.address()

    {:ok, socket} = :gen_tcp.listen(port,
      [:binary, active: false, reuseaddr: true, ifaddr: addr])
    Logger.info "Sink listening on #{:inet.ntoa addr}:#{port}"

    listen_loop(socket)
  end

  defp listen_loop(socket) do
    base_url = WebShell.Config.base_url
    {:ok, client} = :gen_tcp.accept(socket)

    pipe_id = WebShell.Plumber.new_pipe()
    :gen_tcp.send(client, "Your pipe is available at #{base_url}/v/#{pipe_id}\n")
    Logger.info("pipe opened: #{pipe_id}")

    {:ok, pid} = Task.Supervisor.start_child(WebShell.TaskSupervisor, fn ->
      serve(client, pipe_id)
    end)

    :ok = :gen_tcp.controlling_process(client, pid)

    listen_loop(socket)
  end

  defp serve(socket, pipe_id) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, chunk} ->
        case WebShell.Plumber.pipe_input(pipe_id, chunk) do
          :ok ->
            serve(socket, pipe_id)

          :file_too_large ->
            :gen_tcp.send(socket, "max pipe size reached")
        end

      {:error, :closed} ->
        Logger.info("pipe closed: #{pipe_id}")
        WebShell.Plumber.close_pipe(pipe_id)
    end
  end
end
