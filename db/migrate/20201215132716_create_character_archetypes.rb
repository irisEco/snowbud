class CreateCharacterArchetypes < ActiveRecord::Migration[6.0]
  def change
    create_table :character_archetypes, comment: "人物模型表" do |t|
      t.string :name, comment: "人物名字"
      t.string :presentation, comment: "人物背景"
      t.string :pictrues, comment: "图片"
      t.string :feature, comment: "人物特点"
      t.string :gender, comment: "人物性别"
      t.string :description, comment: "人物描述"
      t.string :hobby, comment: "人物爱好"
      t.integer :status, default: 0, comment: "状态"

      t.timestamps
    end
  end
end
