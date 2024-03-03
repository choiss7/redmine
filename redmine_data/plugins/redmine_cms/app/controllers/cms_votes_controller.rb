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

class CmsVotesController < ApplicationController
  unloadable
  before_action :check_params
  before_action :find_cms_page

  helper :cms

  def vote
    case params[:vote]
    when 'up'
      @cms_page.vote_up(User.current, vote_options)
    when 'down'
      @cms_page.vote_down(User.current, vote_options)
    when 'unvote'
      @cms_page.unvote_by(User.current, vote_options)
    end
    redirect_to params[:back_url] || :back
  rescue ActionController::RedirectBackError
    redirect_to cms_page_path(CmsPage.find(RedmineCms.landing_page))
  end

  private

  def find_cms_page
    @cms_page = CmsPage.find_by(:name => params[:id]) || CmsPage.find_by(:id => params[:id])
    render_404 if @cms_page.blank? || !@cms_page.respond_to?(:versions)
  end

  def check_params
    render_404 unless %w(up down unvote).include?(params[:vote])
  end

  def vote_options
    options = {}
    options[:vote_scope]  = params[:vote_scope] if params[:vote_scope]
    options[:vote_weight] = params[:vote_weight].to_i if params[:vote_weight]
    options[:vote_ip]     = request.remote_ip
    options[:vote_by_ip]  = User.current.anonymous?
    options
  end
end
