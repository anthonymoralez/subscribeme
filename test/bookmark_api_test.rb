require 'test_helper'
require 'yaml'
require 'gbookmark_api'

# TEST LIST
# __destroy all bookmarks__
# __create bookmark__
# destroy bookmark
# no url
# no title
# no label
# finding all bookmarks with a given label
# bookmark from xml
#
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

  def teardown
    GBoomarksApi.destroy_all
  end
end
