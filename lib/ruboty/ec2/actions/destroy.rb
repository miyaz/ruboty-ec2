module Ruboty
  module Ec2
    module Actions
      class Destroy < Ruboty::Actions::Base
        def call
          message.reply(destroy)
        end

        private

        def destroy
          # AWSアクセス、その他ユーティリティのインスタンス化
          ec2  = Ruboty::Ec2::Helpers::Ec2.new(message)
          r53  = Ruboty::Ec2::Helpers::Route53.new(message)

          # チャットコマンド情報取得
          ins_name = message[:ins_name]

          ## 現在利用中のインスタンス情報を取得
          ins_infos = ec2.get_ins_infos(ins_name)
          # 存在チェック
          if ins_infos.empty?
            ami_infos = ec2.get_ami_infos(ins_name)
            raise "インスタンス[#{ins_name}]は存在しないよー" if ami_infos.empty?
            raise "インスタンス[#{ins_name}]はアーカイブ済みだよ"
          end

          # ステータス[停止]チェック
          ins_info = ins_infos[ins_name]
          raise "インスタンス[#{ins_name}]は既に削除済みだよ" if ins_info[:state] == "terminated"
          raise "インスタンス[#{ins_name}]を先に停止プリーズ" if ins_info[:state] != "stopped"

          # 削除処理実施
          ins_id = ins_info[:instance_id]
          ec2.destroy_ins(ins_id)

          # Route53 レコード削除処理
          r53.delete_record_sets(ins_name, ins_info[:public_ip])

          "インスタンス[#{ins_name}]を削除したよ"
        rescue => e
          e.message
        end
      end
    end
  end
end

