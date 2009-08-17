class CIJoe
  class Commit < Struct.new(:sha, :user, :project)
    def self.bitly
      @@bitly ||= Bitly.new
    end
        
    def url
      "http://github.com/#{user}/#{project}/commit/#{sha}"
    end
    
    def tiny_url
      begin
        @tiny_url ||= begin 
          bitly_url = self.class.bitly.shorten(url)
          bitly_url.short_url
        end
      rescue 
        url
      end
    end

    def author
      raw_commit_lines[1].split(':')[-1].strip
    end

    def short_author
      raw_commit_lines[1].split(':')[-1].gsub(/(<\w+@.+>)/, '').strip
    end
    
    def committed_at
      raw_commit_lines[2].split(':', 2)[-1]
    end

    def message
      raw_commit_lines[4].split(':')[-1].strip
    end

    def raw_commit
      @raw_commit ||= `git show #{sha}`.chomp
    end

    def raw_commit_lines
      @raw_commit_lines ||= raw_commit.split("\n")
    end
  end
end
