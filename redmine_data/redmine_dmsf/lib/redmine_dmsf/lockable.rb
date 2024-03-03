# encoding: utf-8
# frozen_string_literal: true
#
# Redmine plugin for Document Management System "Features"
#
# Copyright © 2011    Vít Jonáš <vit.jonas@gmail.com>
# Copyright © 2012    Daniel Munn <dan.munn@munnster.co.uk>
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

module RedmineDmsf
  module Lockable

    def locked?
      !lock.empty?
    end

    # lock:
    #   Returns an array with current lock objects that affect the current object
    #   optional: tree = true (show entire tree?)
    def lock(tree = true)
      ret = []
      unless locks.empty?
        locks.each  do |lock|
          ret << lock unless lock.expired?
        end
      end
      if tree && dmsf_folder
        ret = ret | (dmsf_folder.locks.empty? ? dmsf_folder.lock : dmsf_folder.locks)
      end
      ret
    end

    def lock!(scope = :scope_exclusive, type = :type_write, expire = nil, owner = nil)
      # Raise a lock error if entity is locked, but its not at resource level
      existing = lock(false)
      raise DmsfLockError.new(l(:error_resource_or_parent_locked)) if self.locked? && existing.empty?
      unless existing.empty?
        if (existing[0].lock_scope == :scope_shared) && (scope == :scope_shared)
          # RFC states if an item is exclusively locked and another lock is attempted we reject
          # if the item is shared locked however, we can always add another lock to it
          if self.dmsf_folder.locked?
            raise DmsfLockError.new(l(:error_parent_locked))
          else
            existing.each do |l|
              if (l.user.id == User.current.id) && (owner.nil? || (owner.downcase == l.owner&.downcase))
                raise DmsfLockError.new(l(:error_resource_locked))
              end
            end
          end
        else
          raise DmsfLockError.new(l(:error_lock_exclusively)) if scope == :scope_exclusive
        end
      end
      l = DmsfLock.new
      l.entity_id = self.id
      l.entity_type = self.is_a?(DmsfFile) ? 0 : 1
      l.lock_type = type
      l.lock_scope = scope
      l.user = User.current
      l.expires_at = expire
      l.dmsf_file_last_revision_id = self.last_revision.id if self.is_a?(DmsfFile)
      l.owner = owner
      l.save!
      reload # Reload the object being locked in order to contain just created lock when asked
      l
    end

    def unlockable?
      return false unless self.locked?
      existing = self.lock(true)
      # If it's empty, it's a folder that's locked (not root)
      (existing.empty? || (self.dmsf_folder&.locked?)) ? false : true
    end

    # By using the path upwards, surely this would be quicker?
    def locked_for_user?(args = nil)
      return false unless locked?
      shared = nil
      self.dmsf_path.each do |entity|
        locks = entity.locks || entity.lock(false)
        next if locks.empty?
        locks.each do |lock|
          next if lock.expired? # In case we're in between updates
          owner = args[:owner] if args
          owner ||= User.current&.login if lock.owner
          if lock.lock_scope == :scope_exclusive
            return true if (lock.user&.id != User.current.id) || (lock.owner&.downcase != owner&.downcase)
          else
            shared = true if shared.nil?
            if shared && (lock.user&.id == User.current.id) && (lock.owner&.downcase == owner&.downcase) ||
              (args && (args[:scope] == 'shared'))
              shared = false
            end
          end
        end
        return true if shared
      end
      false
    end

    def unlock!(force_file_unlock_allowed = false, owner = nil)
      raise DmsfLockError.new(l(:warning_file_not_locked)) unless self.locked?
      existing = self.lock(true)
      destroyed = false
      # If its empty its a folder that's locked (not root)
      if existing.empty? || (!self.dmsf_folder.nil? && self.dmsf_folder.locked?)
        raise DmsfLockError.new(l(:error_unlock_parent_locked))
      else
        # If entity is locked to you, you aren't the lock originator (or named in a shared lock) so deny action
        # Unless of course you have the rights to force an unlock
        raise DmsfLockError.new(l(:error_only_user_that_locked_file_can_unlock_it)) if (
          self.locked_for_user? && !User.current.allowed_to?(:force_file_unlock, self.project) && !force_file_unlock_allowed)
        # Now we need to determine lock type and do the needful
        if (existing.count == 1) && (existing[0].lock_scope == :exclusive)
          existing[0].destroy
          destroyed = true
        else
          existing.each do |lock|
            owner = User.current&.login if lock.owner && owner.nil?
            if ((lock.user&.id == User.current.id) && (lock.owner&.downcase == owner&.downcase)) || User.current.admin?
              lock.destroy
              destroyed = true
              break
            end
          end
          # At first it was going to be allowed for someone with force_file_unlock to delete all shared by default
          # Instead, they by default remove themselves from shared lock, and everyone from shared lock if they're not
          # on said lock
          if !destroyed && (User.current.allowed_to?(:force_file_unlock, self.project) || force_file_unlock_allowed)
            locks.delete_all
            destroyed = true
          end
        end
      end
      if destroyed
        reload
        locks.reload
      end
      destroyed
    end

  end
end
