class CreateAdmins < ActiveRecord::Migration[6.0]
  def change
    create_table :admins, comment: "系统管理员" do |t|
      ## Database authenticatable
      t.string :name, comment: "姓名"
      t.string :email, comment: "邮箱"
      t.string :phone, comment: "手机号"
      t.string :encrypted_password, comment: "加密密码"

      ## Recoverable
      t.string :reset_password_token, comment: "重置密码令牌"
      t.datetime :reset_password_sent_at, comment: "重置密码时间"

      ## Rememberable
      t.datetime :remember_created_at, comment: "记住创建时间"

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false, comment: "最后次数统计"
      t.datetime :current_sign_in_at, comment: "当前登录时间"
      t.datetime :last_sign_in_at, comment: "最后登录时间"
      t.string   :current_sign_in_ip, comment: "当前登录ip"
      t.string   :last_sign_in_ip, comment: "最后登录ip"

      t.boolean :is_super, default: false, comment: "是否为超管"

      t.timestamps
    end
  end
end
