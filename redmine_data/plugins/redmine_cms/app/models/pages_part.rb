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

class PagesPart < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes

  belongs_to :page, class_name: 'CmsPage', foreign_key: 'page_id'
  belongs_to :part, class_name: 'CmsPart', foreign_key: 'part_id'

  rcrm_acts_as_list scope: 'page_id = \'#{page_id}\''

  scope :active, lambda { where(:status_id => RedmineCms::STATUS_ACTIVE) }
  scope :order_by_type, lambda { includes(:part).order("#{CmsPart.table_name}.part_type").order(:position) }

  before_destroy :touch_page
  after_save :touch_page

  validates_presence_of :page, :part

  def active?
    status_id == RedmineCms::STATUS_ACTIVE
  end

  attr_protected :id if ActiveRecord::VERSION::MAJOR <= 4
  safe_attributes 'page',
                  'part'

  private

  def touch_page
    page.touch
  end
end
