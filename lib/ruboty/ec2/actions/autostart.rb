module Ruboty
  module Ec2
    module Actions
      class Autostart < Ruboty::Actions::Base
        def call
          autostart
        end

        private

        def autostart
          message.reply("TODO: write your logic.")
        rescue => e
          message.reply(e.message)
        end
      end
    end
  end
end
