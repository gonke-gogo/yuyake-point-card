ActiveAdmin.register Stamp do
  actions :index, :show

  filter :visitor
  filter :event
  filter :source, as: :select, collection: Stamp.sources
  filter :checked_in_at

  index do
    selectable_column
    id_column
    column("来場者") { |stamp| link_to stamp.visitor.display_name, admin_visitor_path(stamp.visitor) }
    column("イベント") { |stamp| link_to stamp.event.title, admin_event_path(stamp.event) }
    column :checked_in_at
    column :source
    column("付与した管理者") { |stamp| stamp.granted_by&.email }
    actions
  end

  show do
    attributes_table do
      row("来場者") { link_to resource.visitor.display_name, admin_visitor_path(resource.visitor) }
      row("イベント") { link_to resource.event.title, admin_event_path(resource.event) }
      row :checked_in_at
      row :source
      row("付与した管理者") { resource.granted_by&.email || "-" }
      row :created_at
    end
  end
end
