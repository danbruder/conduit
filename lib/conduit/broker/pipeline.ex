defmodule Conduit.Broker.Pipeline do
  @moduledoc false
  import Conduit.Broker.Scope

  @type name :: atom
  @type plugs :: [Conduit.Plug.t()]
  @type t :: %__MODULE__{
          name: name,
          plugs: plugs
        }

  defstruct name: nil, plugs: []

  @doc """
  Initializes the pipeline scope.
  """
  @spec init(module) :: :ok
  def init(module) do
    Module.register_attribute(module, :pipelines, accumulate: true)
    put_scope(module, nil)
  end

  @doc """
  Starts a scope block.
  """
  @spec start_scope(module, name) :: :ok | no_return
  def start_scope(module, name) do
    if get_scope(module) do
      raise Conduit.BrokerDefinitionError, "pipeline cannot be nested under anything else"
    else
      put_scope(module, %__MODULE__{name: name})
    end
  end

  @doc """
  Ends a scope block.
  """
  @spec end_scope(module) :: :ok
  def end_scope(module) do
    pipeline = get_scope(module)

    Module.put_attribute(module, :pipelines, {pipeline.name, pipeline})
    put_scope(module, nil)
  end

  @doc """
  Sets the pipelines for the scope.
  """
  @spec plug(module, Conduit.Plug.t()) :: :ok
  def plug(module, plug) do
    pipeline = get_scope(module)
    put_scope(module, %{pipeline | plugs: [plug | pipeline.plugs]})
  end
end
