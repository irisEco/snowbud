rack应用程序

# 克隆代码

# Development
  初始化

    bin/setup

  启动server

    shotgun config.ru

  指定端口

    shotgun --port=6000 config.ru

  进入console

    racksh

  进入服务器console

    cap staging rack:console

  进入服务器

    cap staging shell

  启动sidekiq

    bundle exec sidekiq -r ./config/application.rb -C ./config/sidekiq.yml

# 开发说明

1. `config/app_settings` 文件夹下存放的文件都是为需要在服务器上进行配置的文件，比如短信接口配置等
2. `config/settings` 文件夹下存放的文件都是固定配置，即不因部署环境而改变

# 监控

# sidekiq

    cap production sidekiq:monit:config
    cap production sidekiq:monit:monitor

# puma

    cap production puma:monit:config
    cap production puma:monit:monitor

# 地址数据初始化
```shell
    psql -h localhost -p 5432 -U ubuntu interview -f ./db/addresses.sql
```