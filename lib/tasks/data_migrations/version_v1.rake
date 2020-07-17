namespace :data_migrations do
  namespace :version do

    desc "创建超级管理员及普通管理员"
    task :v1_0_1 do
      Admin.create!(name: "admin", email: "service@deercal.com", phone: "18888888888", password: "18888888888", role: 0)
    end
  end
end