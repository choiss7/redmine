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

class DmsfPublicUrlsController < ApplicationController

  model_object DmsfPublicUrl
  before_action :authorize, only: [:create]
  skip_before_action :check_if_login_required, only: [:show]

  def show
    dmsf_public_url = DmsfPublicUrl.where('token = ? AND expire_at >= ?', params[:token], DateTime.current).first
    if dmsf_public_url
      revision = dmsf_public_url.dmsf_file.last_revision
      begin
        # IE has got a tendency to cache files
        expires_in(0.year, 'must-revalidate' => true)
        send_file(revision.disk_file,
                  filename: filename_for_content_disposition(revision.name),
                  type: revision.detect_content_type,
                  disposition: dmsf_public_url.dmsf_file.disposition)
      rescue => e
        Rails.logger.error e.message
        render_404
      end
    else
      render_404
    end
  end

end
