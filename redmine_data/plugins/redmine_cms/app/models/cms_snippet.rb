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

class CmsSnippet < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes
  include RedmineCms::Filterable

  acts_as_attachable_cms
  acts_as_versionable_cms

  validates_presence_of :name, :content
  validates_format_of :name, :with => /\A(?!\d+$)[a-z0-9\-_]*\z/

  after_commit :expire_cache

  attr_protected :id if ActiveRecord::VERSION::MAJOR <= 4
  safe_attributes 'name',
                  'filer_id',
                  'content'

  def used_in_pages
    CmsPage.where("#{CmsPage.table_name}.content LIKE '%{% render_snippet '?' %}%'", name).order(:name)
  end

  def copy_from(arg)
    snippet = arg.is_a?(CmsSnippet) ? arg : CmsSnippet.where(:id => arg).first
    self.attributes = snippet.attributes.dup.except("id", "created_at", "updated_at") if snippet
    self
  end

  def digest
    @generated_digest ||= digest!
  end

  def digest!
    Digest::MD5.hexdigest(content)
  end

  def expire_cache
    used_in_pages.includes(:parts).map(&:expire_cache)
    CmsPage.joins(:layout).where("#{CmsLayout.table_name}.content LIKE '%{% render_snippet '?' %}%'", name).map(&:expire_cache)
  end
end
