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

class CmsPageQuery < Query
  VISIBILITY_PRIVATE = 0
  VISIBILITY_ROLES   = 1
  VISIBILITY_PUBLIC  = 2

  self.queried_class = CmsPage
  self.available_columns = []

  def initialize(attributes = nil, *args)
    super attributes
    self.filters ||= {}
  end

  def initialize_available_filters
    add_available_filter('name', :type => :string, :name => l(:label_cms_name))
    add_available_filter('slug', :type => :string, :name => l(:label_cms_slug))
    add_available_filter('title', :type => :string, :name => l(:label_cms_title))
    add_available_filter('content', :type => :string, :name => l(:label_cms_content))
    add_available_filter('field_name', :type => :string, :name => l(:label_cms_page_field_name))
    add_available_filter('part_name', :type => :string, :name => l(:label_cms_page_part_name))
    add_available_filter('part_description', :type => :string, :name => l(:label_cms_page_part_description))
    add_available_filter('created_at', :type => :date_past, :name => l(:label_cms_created_at))
    add_available_filter('updated_at', :type => :date_past, :name => l(:label_cms_updated_at))
    add_available_filter('part_content', :type => :string, :name => l(:label_cms_page_part_content))

    status_values = [[l(:label_cms_status_locked), RedmineCms::STATUS_LOCKED.to_s], [l(:label_cms_status_active), RedmineCms::STATUS_ACTIVE.to_s]]
    add_available_filter('status_id', :type => :list_optional,
                                      :values => status_values,
                                      :name => l(:label_cms_status))

    visibility_values = [[l(:field_admin), ''], ['Public', 'public'], ['Logged', 'logged']] + Group.where(:type => 'Group').map { |g| [g.name, g.id.to_s] }
    add_available_filter('visibility', :type => :list_optional,
                                       :values => visibility_values,
                                       :name => l(:label_cms_visibility))

    layout_values = CmsLayout.order(:name).map { |l| [l.name, l.id.to_s] }
    add_available_filter('layout_id', :type => :list_optional,
                                      :values => layout_values,
                                      :name => l(:label_cms_layout))

    tags_values = CmsPage.tags_cloud.map { |l| [l.name, l.id.to_s] }
    add_available_filter('cms_page_tags', :type => :list_optional, :name => l(:label_cms_page_tags), :values => tags_values)
  end

  def self.visible(*args)
    user = args.shift || User.current
    scope = CmsPageQuery.all
    if user.admin?
      scope.where("#{table_name}.visibility <> ? OR #{table_name}.user_id = ?", VISIBILITY_PRIVATE, user.id)
    elsif user.memberships.any?
      scope.where("#{table_name}.visibility = ?" +
        " OR (#{table_name}.visibility = ? AND #{table_name}.id IN (" +
          "SELECT DISTINCT q.id FROM #{table_name} q" +
          " INNER JOIN #{table_name_prefix}queries_roles#{table_name_suffix} qr on qr.query_id = q.id" +
          " INNER JOIN #{MemberRole.table_name} mr ON mr.role_id = qr.role_id" +
          " INNER JOIN #{Member.table_name} m ON m.id = mr.member_id AND m.user_id = ?" +
          " WHERE q.project_id IS NULL OR q.project_id = m.project_id))" +
        " OR #{table_name}.user_id = ?",
        VISIBILITY_PUBLIC, VISIBILITY_ROLES, user.id, user.id)
    elsif user.logged?
      scope.where("#{table_name}.visibility = ? OR #{table_name}.user_id = ?", VISIBILITY_PUBLIC, user.id)
    else
      scope.where("#{table_name}.visibility = ?", VISIBILITY_PUBLIC)
    end
  end

  def visible?(user=User.current)
    return true if user.admin?
    case visibility
    when VISIBILITY_PUBLIC
      true
    when VISIBILITY_ROLES
      Member.where(:user_id => user.id).joins(:roles).where(:member_roles => { :role_id => roles.map(&:id) }).any?
    else
      user == self.user
    end
  end

  def objects_scope(options={})
    scope = CmsPage.order(:name)
    options[:search].split(' ').collect{ |search_string| scope = scope.live_search(search_string) } unless options[:search].blank?
    scope = scope.includes((query_includes + (options[:include] || [])).uniq).
      where(statement).
      where(options[:conditions])
    scope
  end

  def query_includes
    [:layout, :author, :fields, :parts]
  end

  def results_scope(options = {})
    objects_scope(options)
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  def sql_for_field_name_field(_field, operator, value)
    string_filter_builder(operator, value, 'name', CmsPageField)
  end

  def sql_for_part_name_field(_field, operator, value)
    string_filter_builder(operator, value, 'name', CmsPart)
  end

  def sql_for_part_description_field(_field, operator, value)
    string_filter_builder(operator, value, 'description', CmsPart)
  end

  def sql_for_part_content_field(_field, operator, value)
    string_filter_builder(operator, value, 'content', CmsPart)
  end

  def sql_for_cms_page_tags_field(_field, operator, value)
    sw = ['!', '!~', '!*'].include?(operator) ? 'NOT' : ''
    page_ids = RedmineCrm::Tagging.where(:taggable_type => CmsPage.name)
    page_ids = page_ids.where(:tag_id => value) unless ['*', '!*'].include?(operator)
    page_ids = page_ids.uniq.pluck(:taggable_id).push(0)

    "(#{CmsPage.table_name}.id #{sw} IN (#{page_ids.join(',')}))"
  end

  def string_filter_builder(operator, value, filter_attr, filter_class)
    sw = ['!', '!~', '!*'].include?(operator) ? 'NOT' : ''
    case operator
    when '=', '!'
      like_value = "LIKE '#{value.first.to_s.downcase}'"
    when '!*'
      like_value = "IS NOT NULL OR #{filter_class.table_name}.#{filter_attr} = ''"
    when '*'
      like_value = "IS NOT NULL OR #{filter_class.table_name}.#{filter_attr} <> ''"
    when '~', '!~'
      like_value = "LIKE '%#{self.class.connection.quote_string(value.first.to_s.downcase)}%'"
    end

    fields_select = "SELECT #{filter_class.table_name}.page_id FROM #{filter_class.table_name} WHERE LOWER(#{filter_class.table_name}.#{filter_attr}) #{like_value}"

    "(#{CmsPage.table_name}.id #{sw} IN (#{fields_select}))"
  end
end
