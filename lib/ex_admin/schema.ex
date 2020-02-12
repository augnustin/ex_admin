defmodule ExAdmin.Schema do
  @moduledoc false

  defp query_to_module(%Ecto.Query{} = q) do
    {_table, module} = q.from.source
    module
  end

  defp resource_to_module(resource) do
    Map.get(resource, :__struct__)
  end

  def primary_key(%Ecto.Query{} = q) do
    primary_key(query_to_module(q))
  end

  def primary_key(module) when is_atom(module) do
    case module.__schema__(:primary_key) do
      [] -> nil
      [key | _] -> key
    end
  end

  def primary_key(resource) do
    if resource_to_module(resource) do
      primary_key(resource_to_module(resource))
    else
      :id
    end
  end

  def get_id(resource) do
    Map.get(resource, primary_key(resource))
  end

  def type(%Ecto.Query{} = q, key) do
    type(query_to_module(q), key)
  end

  def type(module, key) when is_atom(module) do
    module.__schema__(:type, key)
  end

  def type(resource, key), do: type(resource_to_module(resource), key)

  def get_intersection_keys(resource, assoc_name) do
    resource_model = resource.__struct__
    %{through: [link1, link2]} = resource_model.__schema__(:association, assoc_name)
    intersection_model = resource |> Ecto.build_assoc(link1) |> Map.get(:__struct__)

    [
      resource_key: resource_model.__schema__(:association, link1).related_key,
      assoc_key: intersection_model.__schema__(:association, link2).owner_key
    ]
  end
end
