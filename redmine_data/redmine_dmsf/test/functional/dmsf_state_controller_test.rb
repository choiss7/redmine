# encoding: utf-8
# frozen_string_literal: true
#
# Redmine plugin for Document Management System "Features"
#
# Copyright © 2011-21 Karel Pičman <karel.picman@kontron.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require File.expand_path('../../test_helper', __FILE__)

class DmsfStateControllerTest < RedmineDmsf::Test::TestCase
  include Redmine::I18n

  fixtures :dmsf_folders, :dmsf_files, :dmsf_file_revisions

  def setup
    super
    @request.session[:user_id] = @jsmith.id
  end

  def test_user_pref_save_member
    assert @project1
    @role_manager.add_permission! :user_preferences
    post :user_pref_save, params: { id: @project1.id, email_notify: 1, title_format: '%t_%v' }
    assert_redirected_to settings_project_path(@project1, tab: 'dmsf')
    assert_not_nil flash[:notice]
    assert_equal flash[:notice], l(:notice_your_preferences_were_saved)
  end
  
  def test_user_pref_save_member_forbidden
    @role_manager.remove_permission! :user_preferences
    post :user_pref_save, params: { id: @project1.id, email_notify: 1, title_format: '%t_%v' }
    assert_response :forbidden
  end

  def test_user_pref_save_none_member
    # Non Member
    @request.session[:user_id] = @someone.id
    post :user_pref_save, params: { id: @project1.id, email_notify: 1, title_format: '%t_%v' }
    assert_response :forbidden
  end

  def test_user_pref_save_admin
    # Admin - non member
    @request.session[:user_id] = @admin.id
    post :user_pref_save, params: { id: @project1.id, email_notify: 1, title_format: '%t_%v' }
    assert_redirected_to settings_project_path(@project1, tab: 'dmsf')
    assert_not_nil flash[:warning]
    assert_equal flash[:warning], l(:user_is_not_project_member)
  end

end