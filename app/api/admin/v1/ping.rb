module Admin::V1
  class Ping < Admin::V1::Cores::Base
    resources :ping do
      desc "ping..."
      get do
        env = Application.config.env
        data = { pong: "message from admin by #{env}" }
        present data
      end
    end
  end
end
