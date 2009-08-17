class CIJoe
  module Notifier
    module Base
      
      def self.activate
        CIJoe::Build.class_eval do
          include CIJoe::Notifier::Base
        end
        Dir.glob("#{File.expand_path(File.dirname(__FILE__))}/notifiers/*.rb").each do |file|
          require file
          notifiers << eval("CIJoe::Notifier::#{File.basename(file,'.rb').gsub(/(\A|_)(\w)/) { |w| w.tr('_','').upcase }}.activate")
        end
      end
      
      def self.notifiers
        @notifiers ||= []
      end
      
      def send_notifications
        CIJoe::Notifier::Base.notifiers.compact.each { |w| w.notify(self) }
      end
      
    end
  end
end