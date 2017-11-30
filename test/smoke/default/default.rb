# # encoding: utf-8

# Inspec test for recipe fcontext::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe directory('/srv/service1') do
  it { should exist }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its('mode') { should cmp '0755' }
  its('selinux_label') { should eq 'unconfined_u:object_r:var_log_t:s0' }
end

describe file('/srv/service1/file1.txt') do
  it { should exist }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its('mode') { should cmp '0644' }
  its('selinux_label') { should eq 'unconfined_u:object_r:var_t:s0' }
end

describe directory('/srv/service2') do
  it { should exist }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its('mode') { should cmp '0755' }
  its('selinux_label') { should eq 'unconfined_u:object_r:var_log_t:s0' }
end

describe file('/srv/service2/file2.txt') do
  it { should exist }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its('mode') { should cmp '0644' }
  its('selinux_label') { should eq 'unconfined_u:object_r:var_log_t:s0' }
end

describe directory('/srv/service2/directory') do
  it { should exist }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its('mode') { should cmp '0755' }
  its('selinux_label') { should eq 'unconfined_u:object_r:var_log_t:s0' }
end

describe file('/srv/service2/directory/file3.txt') do
  it { should exist }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its('mode') { should cmp '0644' }
  its('selinux_label') { should eq 'unconfined_u:object_r:var_log_t:s0' }
end

