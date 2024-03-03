# encoding: utf-8
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

class WorkflowStartedBy < ActiveRecord::Migration[5.2]

  def change
    rename_column :dmsf_file_revisions, :dmsf_workflow_assigned_by,
                  :dmsf_workflow_assigned_by_user_id
    rename_column :dmsf_file_revisions, :dmsf_workflow_started_by,
                  :dmsf_workflow_started_by_user_id
  end

end