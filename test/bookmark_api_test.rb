require 'test_helper'
require 'yaml'
require 'gbookmark_api'

# TEST LIST
# __destroy all bookmarks__
# __create bookmark__
# __destroy bookmark__
# __create with labels__
# __finding all bookmarks with a given label__
# no url
# no title
# no label
# bookmark from xml

unit_tests do 
  def setup 
    $AUTH_INFO = YAML.load_file('test/bookmarks_api.yml')
    GBoomarksApi.email = $AUTH_INFO['Email']
    GBoomarksApi.passwd = $AUTH_INFO['Passwd']
  end


  test 'bookmarks api should destroy all bookmarks' do 
    GBoomarksApi.create_bookmark("ruby", "http://www.ruby-lang.org/")
    assert_equal 1, GBoomarksApi.find(:all).size

    GBoomarksApi.destroy_all
    assert_equal [], GBoomarksApi.find(:all)
  end

  test 'bookmarks api should create a bookmark' do
    GBoomarksApi.create_bookmark("ruby", "http://www.ruby-lang.org/")
    bookmark = GBoomarksApi.find(:all).first
    assert_equal "ruby", bookmark.title
    assert_equal "http://www.ruby-lang.org/", bookmark.url
  end

  test 'bookmarks api should destroy a bookmark' do
    GBoomarksApi.create_bookmark("java", "http://java.sun.com/")
    bookmark = GBoomarksApi.find(:all).first

    GBoomarksApi.destroy(bookmark)
    assert_equal [], GBoomarksApi.find(:all)
  end

  test 'create bookmarks with labels' do
    GBoomarksApi.create_bookmark("ruby", "http://www.ruby-lang.org/", "programming,ruby")
    bookmark = GBoomarksApi.find(:all).first
    assert_equal "programming,ruby", bookmark.labels
  end

  test 'find bookmarks by label' do
    GBoomarksApi.create_bookmark("ruby", "http://www.ruby-lang.org/", "programming,ruby")
    GBoomarksApi.create_bookmark("java", "http://java.sun.com/", "programming")

    bookmarks = GBoomarksApi.find(:all, :label => 'ruby')

    assert_equal 1, bookmarks.size 
    assert_equal "ruby", bookmarks.first.title
  end

  def teardown
    GBoomarksApi.destroy_all
  end
end
