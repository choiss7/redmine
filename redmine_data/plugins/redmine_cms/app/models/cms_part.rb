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

class CmsPart < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes
  include RedmineCms::Filterable

  belongs_to :page, class_name: 'CmsPage', foreign_key: 'page_id'

  acts_as_attachable_cms
  acts_as_versionable_cms
  acts_as_positioned scope: :page_id

  scope :active, lambda { where(:status_id => RedmineCms::STATUS_ACTIVE) }

  after_commit :touch_page

  validates_presence_of :name, :content, :page
  validates_format_of :name, :with => /\A(?!\d+$)[a-z0-9\-_]*\z/

  [:content, :header, :footer, :sidebar].each do |name, _params|
    src = <<-END_SRC
    def is_#{name}_type?
      self.name.strip.downcase == "#{name}"
    end
    END_SRC
    class_eval src, __FILE__, __LINE__
  end

  attr_protected :id if ActiveRecord::VERSION::MAJOR <= 4
  safe_attributes 'name',
                  'description',
                  'filter_id',
                  'status_id',
                  'page_id',
                  'position',
                  'is_cached',
                  'content'

  def copy_from(arg)
    part = arg.is_a?(CmsPart) ? arg : CmsPart.where(:id => arg).first
    self.attributes = part.attributes.dup.except('id', 'created_at', 'updated_at') if part
    self
  end

  def cache_key
    "#{ page.cache_key + '/' if page.present?}#{super}"
  end

  def active?
    self.status_id == RedmineCms::STATUS_ACTIVE
  end

  def to_s
    ERB::Util.html_escape(name)
  end

  def digest
    @generated_digest ||= digest!
  end

  def digest!
    Digest::MD5.hexdigest(content)
  end

  def title
    description.to_s.strip.blank? ? name : "#{description} (#{name})"
  end

  def self.find_part(*args)
    if args.first && args.first.is_a?(String) && !args.first.match(/^\d*$/)
      find_by_name(*args)
    else
      find(*args)
    end
  end

  def set_content_type(response)
    response.headers['Content-Type'] = filter.content_type.present? ? filter.content_type : 'text/html'
  end

  private

  def touch_page
    return unless page
    page.touch
    page.expire_cache
  end
end
