module Manager::V1
  class Ping < Manager::V1::Cores::Base
    resources :ping do
      desc "ping..."
      get do
        env = Application.config.env
        data = { pong: "message from manager by #{env}" }
        present data
      end
    end
  end
end
