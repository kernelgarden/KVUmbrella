require Logger

defmodule KVServer do
  @moduledoc """
  Documentation for KVServer.
  """

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
                             [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(KVServer.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    socket
    |> read_line
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
      Logger.info "Received From Client"
        data
      {:error, :closed} ->
        Logger.info "Closed Session"
        :error
    end
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
