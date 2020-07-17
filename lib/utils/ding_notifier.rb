module Utils
  class DingNotifier

    # options
    # {
    #   mobile: 'xxx',
    #   is_all: false
    # }
    class << self
      # 业务通知
      # Utils::DingNotifier.info("开户")
      def info(content, options = {})
        opts = {
          title: "通知",
          msg_type: "markdown",
          notify_type: "info",
          text: markdown_text("通知", content) # 【通知】为钉钉业务通知群机器人的关键字，谨慎修改
        }.merge(options)

        notifier(opts)
      end

      # 异常错误提醒
      # Utils::DingNotifier.error("异常提醒", e)
      # Utils::DingNotifier.error("异常提醒", msg: "发生了一个错误")
      def error(content, e = nil, options = {}, msg: nil)
        message = Utils::ExceptionMessage.formater(e) || msg
        opts = {
          title: "异常",
          msg_type: "markdown",
          notify_type: "error",
          text: markdown_text(content, message)
        }.merge(options)

        notifier(opts)
      end

      private

      # 发送钉钉通知
      def notifier(options)
        DingBotService.send_message(options)
      rescue => e

      end

      # 构建markdown消息体
      def markdown_text(title, message)
        hostname = Socket.gethostname
        ip = IPSocket.getaddress(hostname) rescue nil

        <<~STR
          ## #{SERVICES_CONFIG["project_name"]}
          ### #{hostname}:#{ip}
          ### uuid: #{RequestStore.store[:request_id]}
          #{title}

          ```ruby
          #{message}
          ```
        STR
      end
    end
  end
end
