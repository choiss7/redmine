# encoding: utf-8
#
# This file is a part of Redmin CMS (redmine_cms) plugin,
# CMS plugin for redmine
#
# Copyright (C) 2011-2019 RedmineUP
# http://www.redmineup.com/
#
# redmine_cms is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_cms is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_cms.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path('../../test_helper', __FILE__)

class CmsLayoutsControllerTest < ActionController::TestCase
  include RedmineCMS::TestCase::TestHelper
  fixtures :projects, :users

  RedmineCMS::TestCase.create_fixtures([:cms_layouts, :cms_snippets, :cms_pages, :cms_parts,
                                        :cms_page_fields, :cms_menus, :cms_content_versions])

  def setup
    CmsPage.rebuild_tree!
    @layout = CmsLayout.find(1)
    request.env['HTTP_REFERER'] = 'http://test.host/issues/show/1'
    request.env['REMOTE_ADDR'] = '127.0.0.1'
  end

  def test_get_preview
    @request.session[:user_id] = 1
    compatible_request :get, :preview, :id => @layout
    assert_response 200
  end

  def test_get_index
    @request.session[:user_id] = 1
    compatible_request :get, :index
    assert_response 200
  end

  def test_get_new
    @request.session[:user_id] = 1
    compatible_request :get, :new
    assert_response 200
  end

  def test_get_edit
    @request.session[:user_id] = 1
    compatible_request :get, :edit, :id => @layout
    assert_response 200
  end
end
