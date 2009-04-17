require 'mechanize'

module GBoomarksApi 
  BookmarksUrl = 'https://www.google.com/bookmarks'
  class Bookmark
    attr_accessor :title, :url
    def initialize(title, url)
      @title = title
      @url = url
    end
  end
  class << self
    attr_accessor :email, :passwd

    def create_bookmark(title, url)
      c = Connector.authenticate(@email, @passwd)
      c.create_bookmark(title, url)
    end

    def destroy_all
      c = Connector.authenticate(@email, @passwd)
      c.destroy_all
    end

    def find(which)
      c = Connector.authenticate(@email, @passwd)
      bookmarks = c.all_bookmarks_as_xml
      bookmarks.xpath("//bookmark").map do |b|
        title = b.xpath("title").first.content
        url = b.xpath("url").first.content
        Bookmark.new(title, url)
      end
    end
  end

  class Connector
    class << self
      alias :authenticate :new
    end
    attr_reader :agent

    def initialize(email, passwd)
      @agent = WWW::Mechanize.new
      page = agent.get(BookmarksUrl)
      form = page.forms.first
      form.Email = email
      form.Passwd = passwd
      agent.submit form
    end

    def create_bookmark(title, url)
      page = @agent.get "#{BookmarksUrl}/mark?op=edit&output=popup&bkmk=#{url}&title=#{title}&label=itunes"
      page = @agent.submit page.forms.first
    end

    def destroy_all
      page = @agent.get "#{BookmarksUrl}/edit?q=&ceh=1"
      form = page.forms.first
      form['btnD'] = ''
      @agent.submit form
    end

    def all_bookmarks_as_xml
      xml = @agent.get("#{BookmarksUrl}/?output=xml").body
      Nokogiri::XML.parse(xml)
    end
  end
end
