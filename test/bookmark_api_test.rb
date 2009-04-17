require 'test_helper'
require 'yaml'
require 'gbookmark_api'

# TEST LIST
# __destroy all bookmarks__
# create bookmark
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
    GBoomarksApi.create_bookmark("ruby", "http://www.ruby-lang.org")
    assert_equal 1, GBoomarksApi.find(:all).size

    GBoomarksApi.destroy_all
    assert_equal [], GBoomarksApi.find(:all)
  end
end
