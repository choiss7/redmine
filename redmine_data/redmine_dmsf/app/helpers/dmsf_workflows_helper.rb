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

module DmsfWorkflowsHelper

  def render_principals_for_new_dmsf_workflow_users(workflow, dmsf_workflow_step_assignment_id = nil, dmsf_file_revision_id = nil)
    scope = workflow.delegates(params[:q], dmsf_workflow_step_assignment_id, dmsf_file_revision_id)
    principal_count = scope.count
    principal_pages = Redmine::Pagination::Paginator.new principal_count, 100, params['page']
    principals = scope.offset(principal_pages.offset).limit(principal_pages.per_page).to_a

    # Delegation
    if dmsf_workflow_step_assignment_id
      s = content_tag('div',
        content_tag('div', principals_radio_button_tags('step_action', principals), id: 'users_for_delegate'),
        class: 'objects-selection')
    # New step
    else
      s = content_tag('div',
        content_tag('div', principals_check_box_tags('user_ids[]', principals), id: 'users'),
        class: 'objects-selection')
    end

    links = pagination_links_full(principal_pages, principal_count, per_page_links: false) do |text, parameters, _|
      link_to text,
              autocomplete_for_user_dmsf_workflow_path(workflow, parameters.merge(q: params[:q], format: 'js')),
              remote: true
    end

    s + content_tag('span', links, class: 'pagination')
  end

  def dmsf_workflow_steps_options_for_select(steps)
    options = Array.new
    options << [l(:dmsf_new_step), 0]
    steps.each do |step|
      options << [step.name.presence || step.step.to_s, step.step]
    end
    options_for_select(options, 0)
  end

  def dmsf_workflows_for_select(project, dmsf_workflow_id)
    options = Array.new
    options << ['', -1]
    DmsfWorkflow.active.sorted.where(['project_id = ? OR project_id IS NULL', project.id]).each do |wf|
      if wf.project_id
        options << [wf.name, wf.id]
      else
        options << ["#{wf.name} #{l(:note_global)}", wf.id]
      end
    end
    options_for_select(options, selected: dmsf_workflow_id)
  end

  def dmsf_all_workflows_for_select(dmsf_workflow_id)
    options = Array.new
    options << ['', 0]
    DmsfWorkflow.active.sorted.all.each do |wf|
      if wf.project_id
        prj = Project.find_by(id: wf.project_id)
        if User.current.allowed_to?(:manage_workflows, prj)
          # Local approval workflows
          if prj
            options << ["#{wf.name} (#{prj.name})", wf.id]
          else
            options << [wf.name, wf.id]
          end
        end
      else
        # Global approval workflows
        options << ["#{wf.name} #{l(:note_global)}", wf.id]
      end
    end
    options_for_select(options, selected: dmsf_workflow_id)
  end

  def principals_radio_button_tags(name, principals)
    s = +''
    principals.each do |principal|
      s << "<label>#{ radio_button_tag name, principal.id * 10, false, onclick: 'noteMandatory(true);', id: nil } #{h principal}</label>\n"
    end
    s.html_safe
  end

  def change_status_link(workflow)
    url = { controller: 'dmsf_workflows', action: 'update', id: workflow.id }
    if workflow.locked?
      link_to l(:button_unlock), url.merge(dmsf_workflow: { status: DmsfWorkflow::STATUS_ACTIVE }), method: :put, class: 'icon icon-unlock'
    else
      link_to l(:button_lock), url.merge(dmsf_workflow: { status: DmsfWorkflow::STATUS_LOCKED }), method: :put, class: 'icon icon-lock'
    end
  end

  def workflows_status_options_for_select(selected)
    worflows_count_by_status = DmsfWorkflow.global.group('status').count.to_hash
    options_for_select([[l(:label_all), ''],
      ["#{l(:status_active)} (#{worflows_count_by_status[DmsfWorkflow::STATUS_ACTIVE].to_i})", DmsfWorkflow::STATUS_ACTIVE.to_s],
      ["#{l(:status_locked)} (#{worflows_count_by_status[DmsfWorkflow::STATUS_LOCKED].to_i})", DmsfWorkflow::STATUS_LOCKED.to_s]], selected.to_s)
  end

end