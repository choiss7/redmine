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
  module Liquid
    module Tags
      module Votes
        # Render 'voting' url for current page:
        #
        #   {% vote 3 %}        => '/cms/votes/:page_id?vote=up&vote_weight=3&back_url=[current_page_url]'
        #   {% vote 'up' %}     => '/cms/votes/:page_id?vote=up&back_url=[current_page_url]'
        #   {% vote 'unvote' %} => '/cms/votes/:page_id?vote=unvote'
        #   {% vote %}          => '/cms/votes/:page_id?vote=up'
        #
        class VoteUrl < ::Liquid::Tag
          Syntax = /(#{::Liquid::QuotedFragment}+)?/o

          def initialize(tag_name, markup, tokens)
            super
            raise SyntaxError, "Syntax error {% vote 'up' %}" unless markup =~ Syntax
            @vote_param = ::Liquid::Variable.new($1.delete("'")) unless markup.blank?
          end

          def render(context)
            current_page = context.registers[:listener].cms_page_path(context.registers[:page])
            vote_url =
              if @vote_param.nil? || %w(up down unvote).include?(@vote_param.name)
                context.registers[:listener].cms_page_vote_path(context.registers[:page], :vote => @vote_param.nil? ? 'up' : @vote_param.name,
                                                                                          :back_url => current_page)
              else
                context.registers[:listener].cms_page_vote_path(context.registers[:page], :vote => 'up',
                                                                                          :vote_weight => @vote_param.name,
                                                                                          :back_url => current_page)
              end
            vote_url
          end
        end
      end

      ::Liquid::Template.register_tag('vote'.freeze, Votes::VoteUrl)
    end
  end
end
