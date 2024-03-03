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

require 'openssl'
require 'digest/md5'

module RedmineCms
  module Cryptor
    def self.encrypt(data)
      cipher = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC').encrypt
      cipher.key = Digest::SHA1.hexdigest secret_key
      s = cipher.update(data) + cipher.final
      s.unpack('H*')[0].upcase
    end

    def self.decrypt(data)
      cipher = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC').decrypt
      cipher.key = Digest::SHA1.hexdigest secret_key
      s = [data].pack('H*').unpack('C*').pack('c*')
      cipher.update(s) + cipher.final
    rescue OpenSSL::Cipher::CipherError
      nil
    end

    def self.secret_key
      RedmineApp::Application.config.secret_token
    end

    def self.check_timestamp(id, timestamp, checksum)
      Digest::MD5.hexdigest("#{secret_key}/#{id}/#{timestamp}").eql?(checksum) && (timestamp.in_time_zone('UTC') rescue Time.now.utc - 100) > Time.now.utc
    end

    def self.generate_checksum(id, time)
      Digest::MD5.hexdigest("#{secret_key}/#{id}/#{time.utc.to_s(:number)}")
    end
  end
end
