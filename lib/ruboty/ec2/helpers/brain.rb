require 'time'

module Ruboty
  module Ec2
    module Helpers
      class Brain
        CMN_NAMESPACE = 'common'
        GEM_NAMESPACE = 'ec2'
        def initialize(message)
          puts "Ruboty::Ec2::Helpers::Brain.initialize called"
          @channel = Util.new(message).get_channel
          message.robot.brain.data[GEM_NAMESPACE] ||= {}
          @gem_brain = message.robot.brain.data[GEM_NAMESPACE][@channel] ||= {}
          @cmn_brain = message.robot.brain.data[CMN_NAMESPACE] ||= {}
        end

        def save_ins_uptime(ins_name, uptime, yyyymm = nil)
          puts "Ruboty::Ec2::Helpers::Brain.save_ins_uptime called"
          yyyymm = Time.now.strftime('%Y%m') if yyyymm.nil?
          @gem_brain[ins_name] ||= {:uptime => {}}
          @gem_brain[ins_name][:uptime][yyyymm] ||= 0
          @gem_brain[ins_name][:uptime][yyyymm] += uptime
        end

        # 料金計算で使用するためインスタンスタイプ情報を保持
        def save_ins_type(ins_name, ins_type, yyyymm = nil)
          puts "Ruboty::Ec2::Helpers::Brain.save_ins_type called"
          yyyymm = Time.now.strftime('%Y%m') if yyyymm.nil?
          @gem_brain[ins_name] ||= {}
          @gem_brain[ins_name][:ins_type] ||= {}
          @gem_brain[ins_name][:ins_type][yyyymm] = ins_type
        end

        # 料金計算で使用するためRHEL or CentOSの情報を保持
        # os_type には centos or rhel のいずれかを期待
        def save_os_type(ins_name, os_type, yyyymm = nil)
          puts "Ruboty::Ec2::Helpers::Brain.save_os_type called"
          _os_type = (os_type == "centos" ? "centos" : "rhel")
          yyyymm = Time.now.strftime('%Y%m') if yyyymm.nil?
          puts "  ins_name[#{ins_name}]\n  os_type [#{_os_type}]\n  yyyymm  [#{yyyymm}]"
          @gem_brain[ins_name] ||= {}
          @gem_brain[ins_name][:os_type] ||= {}
          @gem_brain[ins_name][:os_type][yyyymm] = _os_type
        end

        def get_ins_infos(yyyymm)
          puts "Ruboty::Ec2::Helpers::Brain.get_ins_infos called"
          ins_infos = {}
          @gem_brain.each do |ins_name, ins_data|
            next if ins_data[:uptime].nil?   or ins_data[:uptime][yyyymm].nil?
            next if ins_data[:ins_type].nil? or ins_data[:ins_type][yyyymm].nil?
            next if ins_data[:os_type].nil?  or ins_data[:os_type][yyyymm].nil?
            ins_infos[ins_name] = {}
            ins_infos[ins_name][:uptime]   = ins_data[:uptime][yyyymm]
            ins_infos[ins_name][:os_type]  = ins_data[:os_type][yyyymm]
            ins_infos[ins_name][:ins_type] = ins_data[:ins_type][yyyymm]
          end
          ins_infos
        end

        def save_slack_user_list(user_infos)
          today = Time.now.strftime('%Y-%m-%d')
          @cmn_brain['slack'] ||= {}
          @cmn_brain['slack'][:last_update] = today
          @cmn_brain['slack'][:user_info]   = user_infos
        end

        def get_slack_user_list
          @cmn_brain['slack'] ||= {}
          @cmn_brain['slack']
        end

      end
    end
  end
end

