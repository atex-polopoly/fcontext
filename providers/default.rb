include Chef::SELinuxPolicy::Helpers

# Support whyrun
def whyrun_supported?
  true
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
  new_resource.updated_by_last_action(true) 
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
    not_if = fcontext_defined(new_resource.file_spec,
                              new_resource.file_type,
                              new_resource.secontext)
    set_fcontext(not_if,
                 true,
                 "-a #{semanage_options(new_resource.file_type)} -t",
                 new_resource.secontext,
                 '')

    if new_resource.recursive
      recursive_not_if = fcontext_defined("#{new_resource.file_spec}(/.*)?",
                                          new_resource.file_type,
                                          new_resource.secontext)
      set_fcontext(recursive_not_if,
                   true,
                   "-a #{semanage_options(new_resource.file_type)} -t",
                   new_resource.secontext,
                   '(/.*)?')
    else
      delete_recursive_only_if = fcontext_defined("#{new_resource.file_spec}(/.*)?",
                                                  new_resource.file_type)
      set_fcontext(nil,
                   delete_recursive_only_if,
                   '-d',
                   '',
                   '(/.*)?')
    end
end

action :delete do
    only_if = fcontext_defined(new_resource.file_spec,
                               new_resource.file_type,
                               new_resource.secontext)
    set_fcontext(nil,
                 only_if,
                 '-d',
                 '',
                 '')

    recursive_only_if = fcontext_defined("#{new_resource.file_spec}(/.*)?",
                                         new_resource.file_type,
                                         new_resource.secontext)
    set_fcontext(nil,
                 recursive_only_if,
                 '-d',
                 '',
                 '(/.*)?')
end
