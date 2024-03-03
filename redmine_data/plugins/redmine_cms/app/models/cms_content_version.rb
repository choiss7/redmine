class CmsContentVersion < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes

  belongs_to :versionable, polymorphic: true
  belongs_to :author, class_name: 'User'

  attr_protected :id if ActiveRecord::VERSION::MAJOR <= 4
  safe_attributes 'author', 'content', 'version', 'comments'

  acts_as_event :title => Proc.new { |o| 
      s = ""
      s = s + l("label_#{o.versionable.class.name.underscore}")
      s = s + " (#{o.versionable.respond_to?(:page) ? "#{o.versionable.page.name}:#{o.versionable.name}": o.versionable.name})"
      if o.versionable.respond_to?(:title) && o.versionable.title.present?
        s = s + ": #{o.versionable.title}"
      elsif o.versionable.respond_to?(:description) && o.versionable.description.present?
        s = s + ": #{o.versionable.description}"
      end
      s
    },
    :description => :comments,
    :group => :versionable,
    :datetime => :created_at,
    :url => Proc.new {|o| {:controller => 'cms_history', :action => 'history', :id => o.versionable.id, :object_type => o.versionable.class.name.underscore}},
    :type => Proc.new {|o| o.versionable.class.name.underscore.gsub('cms_', '') }

  acts_as_activity_provider :timestamp => "#{table_name}.created_at",
                            :author_key => :author_id,
                            :scope => preload(:author)

  scope :visible, lambda {|*args|
    if RedmineCms.allow_edit?
      where('1=1')
    else
      where('1=0')
    end
  }                        

  def current_version?
    versionable.version == version
  end

  def project
    nil
  end

  # Returns the previous version or nil
  def previous
    @previous ||= CmsContentVersion.
      reorder('version DESC').
      includes(:author).
      where('versionable_type = ? AND versionable_id = ? AND version < ?',
            versionable.class, versionable.id, version).first
  end
end
