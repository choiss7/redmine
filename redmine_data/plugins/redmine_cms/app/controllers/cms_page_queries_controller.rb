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

class CmsPageQueriesController < ApplicationController
  before_action :find_query, :except => [:new, :create, :index]

  helper :queries
  include QueriesHelper

  def index
    case params[:format]
    when 'xml', 'json'
      @offset, @limit = api_offset_and_limit
    else
      @limit = per_page_option
    end
    @query_count = CmsPageQuery.visible.count
    @query_pages = Paginator.new @query_count, @limit, params['page']
    @queries = CmsPageQuery.visible.
                    order("#{Query.table_name}.name").
                    limit(@limit).
                    offset(@offset).
                    all
    respond_to do |format|
      format.html
      format.api
    end
  end

  def new
    @query = CmsPageQuery.new
    @query.user = User.current
    @query.build_from_params(params)
    @query.visibility = PeopleQuery::VISIBILITY_PRIVATE unless User.current.admin?
  end

  def create
    @query = CmsPageQuery.new(params[:query])
    @query.user = User.current
    @query.build_from_params(params)
    @query.visibility = PeopleQuery::VISIBILITY_PRIVATE unless User.current.admin?

    if @query.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to url_for(:controller => 'cms_pages', :action => 'index', :query_id => @query.id)
    else
      render :action => 'new', :layout => !request.xhr?
    end
  end

  def edit
  end

  def update
    @query.attributes = params[:query]
    @query.build_from_params(params)
    @query.visibility = PeopleQuery::VISIBILITY_PRIVATE unless User.current.admin?

    if @query.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to url_for(:controller => 'cms_pages', :action => 'index', :query_id => @query.id)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @query.destroy
    redirect_to url_for(:controller => 'cms_page_queries', :action => 'index', :set_filter => 1)
  end

  private

  def find_query
    @query = CmsPageQuery.find(params[:id])
    render_403 unless @query.editable_by?(User.current)
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
