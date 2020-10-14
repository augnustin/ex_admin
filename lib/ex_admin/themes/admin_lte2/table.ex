defmodule ExAdmin.Theme.AdminLte2.Table do
  @moduledoc false
  # import Phoenix.HTML.Tag, only: [content_tag: 2, content_tag: 3]
  import ExAdmin.Table
  import ExAdmin.Gettext
  alias ExAdmin.Utils
  use Xain

  @table_opts [class: "table"]

  def theme_panel(conn, schema) do
    markup do
      resources = get_in(schema, [:table_for, :resources])
      resource_type = case resources do
        [] -> nil
        [%struct{} | _rest] -> struct |> Module.split() |> List.last() |> String.downcase() |> Inflex.pluralize()
      end
      has_active_attribute = case resources do
        [%{is_active: _is_active} | _rest] -> true
        _ -> false
      end
      active_resources = if has_active_attribute, do: Enum.filter(resources, &(&1.is_active)), else: resources

      is_active_filter = conn.query_params[resource_type] != "all"
      displayed_resources = if is_active_filter, do: active_resources, else: resources

      div get_in(schema, [:opts, :box_style]) || ".box" do
        unless get_in(schema, [:opts, :no_header]) do
          div get_in(schema, [:opts, :box_header_style]) || ".box-header.with-border" do
            case displayed_resources do
              [%{id: _id} | _rest] = r ->
                ids = displayed_resources |> Enum.map(&(&1.id)) |> Enum.reject(&is_nil/1)
                a(".btn.btn-default.pull-right Filter in the #{resource_type} list", href: "/admin/#{resource_type}?q%5Bid_in%5D=#{Enum.join(ids, ",")}")
              _ -> nil
            end
            h3() do
              resource_length = length(displayed_resources)
              span("#{resource_length} #{if has_active_attribute && is_active_filter, do: "active"} #{Inflex.inflect(Keyword.get(schema, :name, ""), resource_length)}")
              if has_active_attribute do
                if is_active_filter do
                  query_params = conn.query_params
                  |> Map.put(resource_type, "all")
                  |> URI.encode_query()
                  a(".btn.btn-text (See all #{length(resources)} #{resource_type})", href: "?#{query_params}")
                else
                  query_params = conn.query_params
                  |> Map.put(resource_type, "active")
                  |> URI.encode_query()
                  a(".btn.btn-text (See #{length(active_resources)} active #{resource_type} only)", href: "?#{query_params}")
                end
              end
            end

          end
        end

        div get_in(schema, [:opts, :box_body_style]) || ".box-body" do
          if resource_type do
            do_panel(conn, put_in(schema, [:table_for, :resources], displayed_resources), @table_opts)
          else
            p("No #{String.downcase(schema[:name])} yet.")
          end
        end
      end
    end
  end

  def theme_attributes_table(conn, resource, schema, resource_model) do
    markup do
      div ".box" do
        div ".box-header.with-border" do
          h3(
            schema[:name] ||
              gettext("%{resource_model} Details", resource_model: Utils.humanize(resource_model))
          )
        end

        div ".box-body" do
          do_attributes_table_for(conn, resource, resource_model, schema, @table_opts)
        end
      end
    end
  end

  def theme_attributes_table_for(conn, resource, schema, resource_model) do
    do_attributes_table_for(conn, resource, resource_model, schema, @table_opts)
  end
end
