class DingBotService

  DingBot.access_token = SERVICES_CONFIG["ding_bot"]["access_token"]

  def self.send_message(opts = {})
    return unless SERVICES_CONFIG["ding_bot"]["enable"]

    msg_type = opts[:msg_type] || "text"
    notify_type = opts[:notify_type] || "error"
    access_token = SERVICES_CONFIG["ding_bot"]["#{notify_type}_access_token"]

    message = case msg_type
      when "text"
        DingBot::Message::Text.new(opts[:content], opts[:mobile], opts[:is_all])
      when "link"
        DingBot::Message::Link.new(opts[:title], opts[:text], opts[:msg_url], opts[:pic_url])
      when "markdown"
        DingBot::Message::Markdown.new(opts[:title], opts[:text], opts[:mobile], opts[:is_all])
    end

    client = DingBot::Client.new(access_token: access_token)
    client.send_msg(message)
  rescue => e
    LazyLogger.ding_bot.error("#{e.message}")
  end

end
