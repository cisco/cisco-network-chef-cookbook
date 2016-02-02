Vagrant.configure(2) do |config|
  config.ssh.insert_key = false
  config.vm.boot_timeout = 420
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.network 'private_network', ip: '192.168.1.2', auto_config: false, virtualbox__intnet: 'nxosv_network1'
  config.vm.network 'private_network', auto_config: false, virtualbox__intnet: 'nxosv_network2'
  config.vm.network 'private_network', auto_config: false, virtualbox__intnet: 'nxosv_network3'
  config.vm.network 'private_network', auto_config: false, virtualbox__intnet: 'nxosv_network4'
  config.vm.network 'private_network', auto_config: false, virtualbox__intnet: 'nxosv_network5'
  config.vm.network 'private_network', auto_config: false, virtualbox__intnet: 'nxosv_network6'
  config.vm.network 'private_network', auto_config: false, virtualbox__intnet: 'nxosv_network7'
  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
    vb.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
    vb.customize ['modifyvm', :id, '--nicpromisc4', 'allow-all']
    vb.customize ['modifyvm', :id, '--nicpromisc5', 'allow-all']
    vb.customize ['modifyvm', :id, '--nicpromisc6', 'allow-all']
    vb.customize ['modifyvm', :id, '--nicpromisc7', 'allow-all']
    vb.customize ['modifyvm', :id, '--nicpromisc8', 'allow-all']
  end
  config.vm.provision 'shell', inline: 'echo nameserver 8.8.8.8 > /etc/resolv.conf && sleep 10'
end
