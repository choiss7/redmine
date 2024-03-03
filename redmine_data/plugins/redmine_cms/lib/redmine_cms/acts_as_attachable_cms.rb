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

module RedmineCms
  module ActsAsAttachableCms
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_attachable_cms(options = {})
        cattr_accessor :attachable_options
        self.attachable_options = {}
        attachable_options[:view_permission] = options.delete(:view_permission) || "view_#{name.pluralize.underscore}".to_sym
        attachable_options[:edit_permission] = options.delete(:edit_permission) || "edit_#{name.pluralize.underscore}".to_sym
        attachable_options[:delete_permission] = options.delete(:delete_permission) || "edit_#{name.pluralize.underscore}".to_sym

        if ActiveRecord::VERSION::MAJOR >= 4
          has_many :attachments, lambda { order("#{Attachment.table_name}.created_on ASC, #{Attachment.table_name}.id ASC") },
                                        options.merge(:as => :container, :dependent => :destroy, :inverse_of => :container)
        else
          has_many :attachments, options.merge(:as => :container,
                                               :order => "#{Attachment.table_name}.created_on",
                                               :dependent => :destroy)
        end if self < ActiveRecord::Base

        send :include, RedmineCms::ActsAsAttachableCms::InstanceMethods
        before_save :attach_saved_attachments if self < ActiveRecord::Base
      end
    end

    module InstanceMethods
      def self.included(base)
        base.extend ClassMethods
      end

      def attachments_visible?(user = User.current)
        (respond_to?(:visible?) ? visible?(user) : true)
      end

      def attachments_editable?(user = User.current)
        (respond_to?(:visible?) ? visible?(user) : true) &&
          RedmineCms.allow_edit?(user)
      end

      def attachments_deletable?(user = User.current)
        (respond_to?(:visible?) ? visible?(user) : true) &&
          RedmineCms.allow_edit?(user)
      end

      def saved_attachments
        @saved_attachments ||= []
      end

      def unsaved_attachments
        @unsaved_attachments ||= []
      end

      def save_attachments(attachments, author = User.current)
        if attachments.is_a?(Hash)
          attachments = attachments.stringify_keys
          attachments = attachments.to_a.sort { |a, b|
            if a.first.to_i > 0 && b.first.to_i > 0
              a.first.to_i <=> b.first.to_i
            elsif a.first.to_i > 0
              1
            elsif b.first.to_i > 0
              -1
            else
              a.first <=> b.first
            end
          }
          attachments = attachments.map(&:last)
        end
        if attachments.is_a?(Array)
          attachments.each do |attachment|
            next unless attachment.is_a?(Hash)
            a = nil
            if file = attachment['file']
              next unless file.size > 0
              a = Attachment.create(:file => file, :author => author)
            elsif token = attachment['token']
              a = Attachment.find_by_token(token)
              next unless a
              a.filename = attachment['filename'] if attachment['filename'].present?
              a.content_type = attachment['content_type'] if attachment['content_type'].present?
            end
            next unless a
            a.description = attachment['description'].to_s.strip
            if a.new_record?
              unsaved_attachments << a
            else
              saved_attachments << a
            end
          end
        end
        { :files => saved_attachments, :unsaved => unsaved_attachments }
      end

      def attach_saved_attachments
        saved_attachments.each do |attachment|
          attachments << attachment
        end
      end

      module ClassMethods
      end
    end
  end
end

ActiveRecord::Base.send(:include, RedmineCms::ActsAsAttachableCms)
