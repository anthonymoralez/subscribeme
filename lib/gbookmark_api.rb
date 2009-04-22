require 'rubygems'
require 'mechanize'

module GBoomarksApi 
  BookmarksUrl = 'https://www.google.com/bookmarks'
  class Bookmark
    attr_accessor :title, :url
    def initialize(xml_node)
      @xml_node = xml_node
      @title = @xml_node.xpath("title").first.content
      @url = @xml_node.xpath("url").first.content
    end

    def id
        @id ||= @xml_node.xpath("id").first.content 
    end
    def labels
        @labels ||= @xml_node.xpath("labels/label").map { |l| l.content }.join(',')
    end
  end

  class << self
    attr_accessor :email, :passwd 
    def connector
      @@connector ||= Connector.authenticate(@email, @passwd)
    end

    def create_bookmark(title, url, labels="")
      self.connector.create_bookmark(title, url, labels)
    end

    def destroy(bookmark)
      self.connector.destroy(bookmark)
    end

    def destroy_all
      self.connector.destroy_all
    end

    def find_all(options={})
      bookmarks = self.connector.all_bookmarks_as_xml(options)
      bookmarks.xpath("//bookmark").map do |b|
        Bookmark.new(b)
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

    def destroy(bookmark)
      page = agent.get(BookmarksUrl)
      sig = page.forms.select { |f| !f["sig"].nil? }.first["sig"]
      @agent.post "#{BookmarksUrl}/mark", 'dlq' => bookmark.id, "sig" => sig
    end

    def create_bookmark(title, url, labels="")
      page = @agent.get "#{BookmarksUrl}/mark?op=edit&output=popup&bkmk=#{url}&title=#{URI.escape(title)}&labels=#{URI.escape(labels)}"
      page =@agent.submit page.forms.first
    end

    def destroy_all
      page = @agent.get "#{BookmarksUrl}/edit?q=&ceh=1"
      form = page.forms.first
      form['btnD'] = ''
      @agent.submit form
    end

    def all_bookmarks_as_xml(options = {})
      url = "#{BookmarksUrl}/?output=xml"
      url << "&q=label:#{options[:label]}" unless options[:label].nil?
      xml = @agent.get(url).body
      Nokogiri::XML.parse(xml)
    end
  end
end
