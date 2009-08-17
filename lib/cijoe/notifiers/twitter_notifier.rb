class CIJoe
  module Notifier
    class TwitterNotifier
      def self.activate
        if valid_config?
          require 'twitter'
          puts "Loaded Twitter notifier"
          new
        else
          puts "Can't load twitter notifier."
          puts "Please add the following to your project's .git/config:"
          puts "[twitter]"
          puts "\tuser = username"
          puts "\tpass = passw0rd"
          nil
        end
      end

      def self.config
        @config ||= {
          :user      => Config.twitter.user.to_s,
          :pass      => Config.twitter.pass.to_s
        }
      end

      def self.valid_config?
        config.all? { |key, value| !value.empty? }
      end

      def notify(build)
        self.class.twitter.update "#{short_message(build)}. #{build.commit.tiny_url}"
      end

    private
      def self.twitter
        @twitter ||= begin
          config = TwitterNotifier.config
          httpauth = Twitter::HTTPAuth.new(config[:user], config[:pass])
          base = Twitter::Base.new(httpauth)
        end
      end

      def short_message(build)
        "Build #{build.short_sha} of #{build.project} #{build.worked? ? "was successful" : "failed"} (#{build.commit.short_author})"
      end
    end
  end
end