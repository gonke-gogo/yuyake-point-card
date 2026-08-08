ActiveAdmin.register Rank do
  permit_params :name, :min_stamps, :benefit_description, :position

  index do
    selectable_column
    id_column
    column :name
    column :min_stamps
    column :benefit_description
    column :position
    actions
  end

  filter :name_cont, label: "名前"
  filter :min_stamps

  form do |f|
    f.inputs do
      f.input :name
      f.input :min_stamps, hint: "このスタンプ数以上でこのランクになります"
      f.input :benefit_description, label: "特典"
      f.input :position, hint: "並び順(小さいほど上位)"
    end
    f.actions
  end
end
