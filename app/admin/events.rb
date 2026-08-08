ActiveAdmin.register Event do
  permit_params :title, :held_on, :venue, :status, :venue_lat, :venue_lng, :allowed_radius_meters

  filter :title_cont, label: "タイトル"
  filter :held_on
  filter :status, as: :select, collection: Event.statuses

  index do
    selectable_column
    id_column
    column :title
    column :held_on
    column :venue
    column :status
    column("スタンプ数") { |event| event.stamps.size }
    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :held_on
      row :venue
      row :status
      row("会場座標") { resource.venue_lat.present? ? "#{resource.venue_lat}, #{resource.venue_lng}" : "未設定(位置情報チェックはスキップされます)" }
      row :allowed_radius_meters
      row :created_at
      row :updated_at
    end

    panel "来場者" do
      table_for resource.stamps.includes(:visitor).order(checked_in_at: :desc) do
        column("来場者") { |stamp| stamp.visitor.display_name }
        column("チェックイン日時") { |stamp| stamp.checked_in_at }
        column("付与経路") { |stamp| stamp.source }
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :held_on, as: :datepicker
      f.input :venue
      f.input :status, as: :select, collection: Event.statuses.keys
    end
    f.inputs "位置情報チェック(任意)" do
      f.input :venue_lat, label: "会場の緯度", hint: "空欄の場合、チェックイン時の位置情報チェックはスキップされます"
      f.input :venue_lng, label: "会場の経度"
      f.input :allowed_radius_meters, label: "許容半径(メートル)"
    end
    f.actions
  end
end
