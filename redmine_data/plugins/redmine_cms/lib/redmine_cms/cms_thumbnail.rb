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

require 'fileutils'

module RedmineCms
  module Thumbnail
    extend Redmine::Utils::Shell

    def self.generate(attachment, options = {})
      if attachment.thumbnailable? && attachment.readable?
        size, width, height = [0, 0, 0]
        if options[:size].to_s.match(/(\d+)x(\d+)/i)
          width = $1
          height = $2
          size = [width, height].max
          crop_option = "#{width}x#{height}"
          size_option = "#{crop_option}^"
        elsif options[:size].to_s.match(/(\d+)/)
          size = $1
          size_option = "#{size}>"
        end

        return attachment.diskfile unless size.to_i > 0
        sharpen_option = (options[:sharpen].present? || size.to_i <= 32) ? '0.7x6' : ''
        alpha_option = '-alpha on -background none' if options[:alpha].present? && options[:alpha].to_s.match(/on|true/i)

        target = File.join(attachment.class.thumbnails_storage_path, "#{attachment.id}_#{attachment.digest}_#{crop_option || size_option.gsub(/^|>/, '')}.thumb")
        begin
          return nil unless Redmine::Thumbnail.convert_available?
          unless File.exists?(target)
            # Make sure we only invoke Imagemagick if the file type is allowed
            unless File.open(attachment.diskfile) { |f| Redmine::Thumbnail::ALLOWED_TYPES.include? MimeMagic.by_magic(f).try(:type) }
              return nil
            end
            directory = File.dirname(target)
            unless File.exists?(directory)
              FileUtils.mkdir_p directory
            end
            sharpen_cmd = "-sharpen #{shell_quote sharpen_option}" if sharpen_option.present?
            crop_cmd = "#{alpha_option} -gravity center -extent #{shell_quote crop_option}" if crop_option
            thumbnail_cmd = "-resize #{shell_quote size_option} -strip"
            convert_cmd = [thumbnail_cmd, crop_cmd, sharpen_cmd].join(" ")

            cmd = "#{shell_quote Redmine::Thumbnail::CONVERT_BIN} #{shell_quote attachment.diskfile} #{convert_cmd} #{shell_quote target}"
            unless system(cmd)
              logger.error "Creating thumbnail failed (#{$?}):\nCommand: #{cmd}" if logger
              return nil
            end
          end
          target
        rescue => e
          logger.error "An error occured while generating thumbnail for #{attachment.disk_filename} to #{target}\nException was: #{e.message}" if logger
          return nil
        end
      end
    end

    def self.logger
      Rails.logger
    end
  end
end
