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
        Net::HTTP.post_form(self.class.base_uri, { 'status' => short_message(build) })
      end

    private
    
      def self.base_uri
        @@base_uri ||= URI.parse( "http://#{config[:user]}:#{config[:pass]}@twitter.com/statuses/update.json" )
      end

      def short_message(build)
        "[#{build.project}] build #{build.short_sha} by #{build.commit.short_author} #{build.worked? ? "was successful" : "failed"}. #{build.commit.tiny_url}"
      end
    end
  end
end