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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

require File.expand_path('../../test_helper', __FILE__)

class DmsfFolderPermissionTest < RedmineDmsf::Test::UnitTest

  fixtures :dmsf_folder_permissions, :dmsf_folders, :dmsf_files, :dmsf_file_revisions

  def setup
    super
    @permission1 = DmsfFolderPermission.find 1
  end

  def test_scope
    assert_equal 2, DmsfFolderPermission.all.size
  end

  def test_scope_users
    assert_equal 1, DmsfFolderPermission.users.all.size
  end

  def test_scope_roles
    assert_equal 1, DmsfFolderPermission.roles.all.size
  end

  def test_copy_to
    permission = @permission1.copy_to(@folder1)
    assert permission
    assert_equal @folder1.id, permission.dmsf_folder_id
    assert_equal @permission1.object_id, permission.object_id
    assert_equal @permission1.object_type, permission.object_type
  end

end
