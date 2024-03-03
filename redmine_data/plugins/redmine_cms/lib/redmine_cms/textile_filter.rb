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

class TextileFilter < TextFilter
  include Rails.application.routes.url_helpers

  def self.mine_type
    'textilemixedliquid'
  end

  def content_type
    'text/plain'
  end

  def filter(text, cms_object)
    s = RedmineCms::Textile::Formatter.new(text).to_html
    s = parse_inline_attachments(s, cms_object, true, {})
    if s.match(TOC_RE)
      parsed_headings = parse_headings(s, cms_object)
      replace_toc(s, parsed_headings) if parsed_headings.any?
    end
    s
  end

  def parse_inline_attachments(text, obj, only_path, options)
    return if options[:inline_attachments] == false
    # when using an image link, try to use an attachment, if possible
    attachments = options[:attachments] || []
    attachments += obj.attachments if obj.respond_to?(:attachments)
    if attachments.present?
      text.gsub(/src="([^\/"]+\.(bmp|gif|jpg|jpe|jpeg|png))"(\s+alt="([^"]*)")?/i) do |m|
        filename, ext, alt, alttext = $1.downcase, $2, $3, $4
        # search for the picture in attachments
        if found = Attachment.latest_attach(attachments, CGI.unescape(filename))
          image_url = download_named_attachment_url(found, found.filename, :only_path => only_path)
          desc = found.description.to_s.gsub('"', '')
          if !desc.blank? && alttext.blank?
            alt = " title=\"#{desc}\" alt=\"#{desc}\""
          end
          "src=\"#{image_url}\"#{alt}"
        else
          m
        end
      end
    else
      text
    end
  end

  HEADING_RE = /(<h(\d)( [^>]+)?>(.+?)<\/h(\d)>)/i unless const_defined?(:HEADING_RE)

  def parse_headings(text, obj, options = {})
    return if options[:headings] == false
    heading_anchors = {}
    parsed_headings = []
    text.gsub!(HEADING_RE) do
      level, attrs, content = $2.to_i, $3, $4
      item = ActionController::Base.helpers.strip_tags(content).strip
      anchor = item.gsub(%r{[^\s\-\p{Word}]}, '').gsub(%r{\s+(\-+\s*)?}, '-')
      # used for single-file wiki export
      anchor = "#{obj.name}_#{anchor}" if options[:wiki_links] == :anchor && (obj.is_a?(CmsPage) || obj.is_a?(CmsPart) || obj.is_a?(CmsSnippet))
      heading_anchors[anchor] ||= 0
      idx = (heading_anchors[anchor] += 1)
      if idx > 1
        anchor = "#{anchor}-#{idx}"
      end
      parsed_headings << [level, anchor, item]
      "<a name=\"#{anchor}\"></a>\n<h#{level} #{attrs}>#{content}<a href=\"##{anchor}\" class=\"header-anchor\"></a></h#{level}>"
    end
    parsed_headings
  end

  TOC_RE = /<p>\[\[toc\]\]<\/p>/i unless const_defined?(:TOC_RE)

  # Renders the TOC with given headings
  def replace_toc(text, headings)
    text.gsub!(TOC_RE) do
      # Keep only the 4 first levels
      headings = headings.select { |level, _anchor, _item| level <= 4 }
      if headings.empty?
        ''
      else
        out = '<ul class="toc"><li>'
        root = headings.map(&:first).min
        current = root
        started = false
        headings.each do |level, anchor, item|
          if level > current
            out << '<ul><li>' * (level - current)
          elsif level < current
            out << "</li></ul>\n" * (current - level) + '</li><li>'
          elsif started
            out << '</li><li>'
          end
          out << "<a href=\"##{anchor}\">#{item}</a>"
          current = level
          started = true
        end
        out << '</li></ul>' * (current - root)
        out << '</li></ul>'
      end
    end
  end
end
