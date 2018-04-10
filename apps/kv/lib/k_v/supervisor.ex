defmodule KV.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      # Registry가 KV.BucketSupervisor를 필요로 하기 때문에 순서가 중요합니다.
      {DynamicSupervisor, name: KV.BucketSupervisor, strategy: :one_for_one},
      {KV.Registry, name: KV.Registry}
    ]

    # Registry가 종료 될떄 DynamicSupervisor도 같이 재시작 되야하기 때문이다.
    Supervisor.init(children, strategy: :one_for_all)
  end
end
