#
# Cookbook Name:: libvirt_kvm_domain
# Recipe:: default
#
# Copyright 2014, CLODO
#
# All rights reserved - Do Not Redistribute
#

node["libvirt"]["kvm"]["domains"].each do |name,params|
  libvirt_domain name do
    provider 'libvirt_domain_kvm'
    vcpu params['vcpu']
    memory params['memory']
    if params['arch']
      arch params['arch']
    else
      arch 'amd64'
    end
    if params['autostart']
      action [:define, :create, :autostart]
    else
      action [:define, :create]
    end
    boot params['boot'] if params['boot']
  end
  if params['disks']
    params['disks'].each do |disk,disk_options|
      libvirt_disk_device disk do
        type disk_options['type'] if disk_options['type']
        bus disk_options['bus'] if disk_options['bus']
        source disk_options['source']
        target disk_options['target'] if disk_options['target']
        domain name
        action :nothing
        subscribes :attach, resources(:libvirt_domain => name), :immediately
      end
    end
  end
  if params['networks']
    params['networks'].each do |mac,net_options|
      libvirt_network_interface mac do
        type net_options['type'] if net_options['type']
        model net_options['model'] if net_options['model']
        source net_options['source']
        domain name
        action :nothing
        subscribes :attach, resources(:libvirt_domain => name), :immediately
      end
    end
  end
end
