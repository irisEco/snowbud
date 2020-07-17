module Client::V1
  class Ping < Client::V1::Cores::Base
    resources :ping do
      desc "ping..."
      get do
        env = Application.config.env
        data = { pong: "message from client by #{env}" }
        present data
      end
    end
  end
end
