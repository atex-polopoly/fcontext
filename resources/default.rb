# Manages file specs in SELinux
# See http://docs.fedoraproject.org/en-US/Fedora/13/html/SELinux_FAQ/index.html#id3715134

actions :set, :delete, :relabel
default_action :set
attribute :file_spec, kind_of: String, name_attribute: true
attribute :secontext, kind_of: String
attribute :file_type, kind_of: String, default: 'a', equal_to: %w(a f d c b s l p)
attribute :recursive, default: false
