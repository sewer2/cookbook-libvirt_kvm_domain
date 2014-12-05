#
# Cookbook Name:: libvirt_kvm_domain
# Recipe:: default
#
# Copyright 2014, CLODO
#
# All rights reserved - Do Not Redistribute
#
reserve=['disks', 'networks', 'autostart']
kvms=node['libvirt']['kvm']['domains'].select{ |k,v| k!= 'default_params' }
default=node['libvirt']['kvm']['domains']['default_params'].to_hash

kvms.each do |name,params|
  config = Chef::Mixin::DeepMerge.merge(params.to_hash, default)
  autostart=config['autostart']
  reserve.each do |word|
    config.delete_if{ |k, v| k == word }
  end
  libvirt_domain name do
    provider 'libvirt_domain_kvm'
    conf_mash config
    if autostart
      action [:define, :create, :autostart]
    else
      action [:define, :create]
    end
  end
  if config['disks']
    config['disks'].each do |disk,disk_options|
      libvirt_disk_device disk do
        type disk_options['type'] if disk_options['type']
        bus disk_options['bus'] if disk_options['bus']
        source disk_options['source']
        target disk_options['target'] if disk_options['target']
        domain name
        action :attach
      end
    end
  end
  if config['networks']
    config['networks'].each do |mac,net_options|
      libvirt_network_interface mac do
        type net_options['type'] if net_options['type']
        model net_options['model'] if net_options['model']
        source net_options['source']
        domain name
        action :attach
      end
    end
  end
end
