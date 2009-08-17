class CIJoe
  module Notifier
    class Campfire
      def self.activate
        if valid_config?
          require 'tinder'
          puts "Loaded Campfire notifier"
          new
        else
          puts "Can't load Campfire notifier."
          puts "Please add the following to your project's .git/config:"
          puts "[campfire]"
          puts "\tuser = your@campfire.email"
          puts "\tpass = passw0rd"
          puts "\tsubdomain = whatever"
          puts "\troom = Awesomeness"
          puts "\tssl = false"
          nil
        end
      end

      def self.config
        @config ||= {
          :subdomain => Config.campfire.subdomain.to_s,
          :user      => Config.campfire.user.to_s,
          :pass      => Config.campfire.pass.to_s,
          :room      => Config.campfire.room.to_s,
          :ssl       => Config.campfire.ssl.strip == 'true'
        }
      end

      def self.valid_config?
        %w( subdomain user pass room ).all? do |key|
          !config[key.intern].empty?
        end
      end

      def notify(build)
        room.speak "#{short_message(build)}. #{build.commit.url}"
        room.paste full_message(build.commit) if failed?
        room.leave
      end

    private
      def room
        @room ||= begin
          config = Campfire.config
          options = {}
          options[:ssl] = config[:ssl] ? true : false
          campfire = Tinder::Campfire.new(config[:subdomain], options)
          campfire.login(config[:user], config[:pass])
          campfire.find_room_by_name(config[:room])
        end
      end

      def short_message(build)
        "Build #{build.short_sha} of #{build.project} #{build.worked? ? "was successful" : "failed"}"
      end

      def full_message(commit)
        <<-EOM
  Commit Message: #{commit.message}
  Commit Date: #{commit.committed_at}
  Commit Author: #{commit.author}

  #{clean_output}
  EOM
      end
    end
  end
end
