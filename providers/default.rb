include Chef::SELinuxPolicy::Helpers

# Support whyrun
def whyrun_supported?
  true
end

# Make a file spec suffix from a filter spec:-
# * = Make an 'all files' regex
# abc, 123, a2c = Alpha/numeric, make a file suffix regex
# (/.*[\.|_]log$) = Non alpha/numeric, assume regex given and pass throgh
def make_file_spec_suffix(filter)
  case filter
  when '*'
    '/(.*)'
  when /^[a-zA-Z0-9]+$/
    "/(.*#{filter}$)"
  else
    filter
  end
end

# Produces a string containing a Shell command pipeline that tells you if a given fcontext is defined
def fcontext_defined(file_spec, file_type, label = nil)
  file_hash = {
    'a' => 'all files',
    'f' => 'regular file',
    'd' => 'directory',
    'c' => 'character device',
    'b' => 'block device',
    's' => 'socket',
    'l' => 'symbolic link',
    'p' => 'named pipe',
  }

   label_matcher = label ? "system_u:object_r:#{Regexp.escape(label)}:s0\\s*$" : ''
  "semanage fcontext -l | grep -qP '^#{Regexp.escape(file_spec)}\\s+#{Regexp.escape(file_hash[file_type])}\\s+#{label_matcher}'"
end

def semanage_options(file_type)
  # Set options for file_type
  if node['platform_family'].include?('rhel') && Chef::VersionConstraint.new('< 7.0').include?(node['platform_version'])
    case file_type
    when 'a' then '-f ""'
    when 'f' then '-f --'
    else; "-f -#{file_type}"
    end
  else
    "-f #{file_type}"
  end
end

use_inline_resources

# Run restorecon to fix label
action :relabel do
  res = shell_out!('restorecon', '-iRv', new_resource.file_spec)
  new_resource.updated_by_last_action(!res.stdout.strip.empty?)
end

def set_fcontext (not_if, only_if, commands, secontext, file_spec_suffix )
  execute "selinux-fcontext-#{new_resource.secontext}-set" do
    command "/usr/sbin/semanage fcontext #{commands} #{secontext} '#{new_resource.file_spec}#{file_spec_suffix}'"
    not_if not_if unless not_if.nil?
    only_if only_if.to_s unless only_if.nil?
    only_if { use_selinux }
    notifies :relabel, new_resource, :immediate
  end
end

action :set do
  file_spec_suffix = make_file_spec_suffix(new_resource.filter) || ''

  not_if = fcontext_defined(
    "#{new_resource.file_spec}#{file_spec_suffix}",
    new_resource.file_type,
    new_resource.secontext
  )
  set_fcontext(
    not_if, true,
    "-a #{semanage_options(new_resource.file_type)} -t",
    new_resource.secontext,
    file_spec_suffix
  )

  # Apply context to file_spec if 'all' recurse option

  if new_resource.filter == '*'
    not_if = fcontext_defined(
      new_resource.file_spec,
      new_resource.file_type,
      new_resource.secontext
    )
    set_fcontext(
      not_if, true,
      "-a #{semanage_options(new_resource.file_type)} -t",
      new_resource.secontext, ''
    )
  end

end

action :delete do
  file_spec_suffix = make_file_spec_suffix(new_resource.filter) || ''

  only_if = fcontext_defined(
    "#{new_resource.file_spec}#{file_spec_suffix}",
    new_resource.file_type,
    new_resource.secontext
  )
  set_fcontext(
    nil, only_if, '-d', '',
    file_spec_suffix
  )

  #  Apply context to file_spec if 'all' recurse option

  if new_resource.filter == '*'
    only_if = fcontext_defined(
      new_resource.file_spec,
      new_resource.file_type,
      new_resource.secontext
    )
    set_fcontext(
      nil, only_if, '-d', '', ''
    )
  end

end
