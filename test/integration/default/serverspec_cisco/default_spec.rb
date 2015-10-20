require 'spec_helper'

describe 'cisco-test::default' do
  before(:all) do
    @running_config = get_running_config
  end

  it 'has a running config with a version string' do
    expect(@running_config).to match(/^version/)
  end

  it 'writes out a file using the file resource' do
    expect(file('/tmp/file_resource.txt')).to be_file
    expect(file('/tmp/file_resource.txt').md5sum).to eq '0bb1180130fb53d2d0d0bd45950863bf'
  end

  it 'writes out a file using the template resource' do
    expect(file('/tmp/template_resource.txt')).to be_file
    expect(file('/tmp/template_resource.txt').md5sum).to eq '4919580c509a7f0504d3e01fd84a0a08'
  end

  describe 'cisco_ospf' do
    before(:all) do
      @running_config = get_running_config
    end

    it 'has the OSPF feature enabled' do
      expect(@running_config).to match(/^feature ospf/)
    end

    it 'has a Sample OSPF process' do
      expect(@running_config).to match(/^router ospf Sample/)
    end

    it 'does not have a NotHere OSPF process' do
      expect(@running_config).not_to match(/^router ospf NotHere/)
    end
  end

  describe 'cisco_command_config' do
    before(:all) do
      @running_config = get_running_config('interface Ethernet1/9')
    end

    it 'manually set a description in eth1/9' do
      expect(@running_config).to match(/description cookbook-test/)
    end
  end

  describe 'cisco_interface' do
    context 'Ethernet1/1 layer 3 interface' do
      before(:all) do
        @running_config = get_running_config('interface Ethernet1/1')
      end

      it 'has switchport mode disabled' do
        expect(@running_config).to match(/no switchport/)
      end

      it 'has a properly-configured IP address' do
        expect(@running_config).to match(/^  ip address 10.1.1.1\/24/)
      end

      it 'has a proxy ARP enabled' do
        expect(@running_config).to match(/^  ip proxy-arp/)
      end

      it 'is not shutdown' do
        expect(@running_config).to match(/^  no shutdown/)
      end
    end

    context 'Ethernet1/2 layer 2 interface' do
      before(:all) do
        @running_config = get_running_config('interface Ethernet1/2')
      end

      it 'is not shutdown' do
        expect(@running_config).not_to match(/^  shutdown/)
      end

      it 'is configured with an access vlan' do
        expect(@running_config).to match(/^  switchport access vlan 100/)
      end
    end
  end

  describe 'cisco_interface_ospf' do
    context 'Ethernet1/1 configured for OSPF' do
      before(:all) do
        @running_config = get_running_config('interface Ethernet1/1')
      end

      it 'is configured for OSPF in the correct process and area' do
        expect(@running_config).to match(/^  ip router ospf Sample area 0.0.0.200/)
      end

      it 'is configured for authentication' do
        expect(@running_config).to match(/^  ip ospf authentication message-digest/)
      end

      it 'is configured with the proper OSPF auth key' do
        expect(@running_config).to match(/^  ip ospf message-digest-key 7 md5 3 386c0565965f89de/)
      end

      it 'has a properly-configured cost' do
        expect(@running_config).to match(/^  ip ospf cost 200/)
      end

      it 'has a properly-configured dead interval' do
        expect(@running_config).to match(/^  ip ospf dead-interval 200/)
      end

      it 'has a properly-configured hello interval' do
        expect(@running_config).to match(/^  ip ospf hello-interval 200/)
      end

      it 'is configured as a passive interface' do
        expect(@running_config).to match(/^  ip ospf passive-interface/)
      end
    end

    context 'Ethernet1/2 OSPF configuration destroyed' do
      before(:all) do
        @running_config = get_running_config('interface Ethernet1/2')
      end

      it 'is not configured for ospf' do
        expect(@running_config).not_to match(/^ospf/)
      end
    end
  end

  describe 'cisco_ospf_vrf' do
    context 'default vrf' do
      before(:all) do
        @running_config = get_running_config('ospf | section "router ospf Sample"')
      end

      it 'has properly-configured log adjacency' do
        expect(@running_config).to match(/^  log-adjacency-changes detail/)
      end

      it 'has properly-configured spf timers' do
        expect(@running_config).to match(/^  timers throttle spf 250 1500 5500/)
      end

      it 'has properly-configured lsa timers' do
        expect(@running_config).to match(/^  timers throttle lsa 5 5500 5600/)
      end

      it 'has properly-configured auto-cost settings' do
        expect(@running_config).to match(/^  auto-cost reference-bandwidth 45000/)
      end

      it 'has correct default metric' do
        expect(@running_config).to match(/^  default-metric 5/)
      end
    end

    context 'management vrf' do
      before(:all) do
        @running_config = get_running_config('ospf | section "router ospf Sample" | begin "vrf management"')
      end

      it 'has properly-configured log adjacency' do
        expect(@running_config).to match(/^    log-adjacency-changes$/)
      end

      it 'has properly-configured spf timers' do
        expect(@running_config).to match(/^    timers throttle spf 277 1700 5700/)
      end

      it 'has properly-configured lsa timers' do
        expect(@running_config).to match(/^    timers throttle lsa 8 5600 5800/)
      end

      it 'has properly-configured auto-cost settings' do
        expect(@running_config).to match(/^    auto-cost reference-bandwidth 46000/)
      end

      it 'has correct default metric' do
        expect(@running_config).to match(/^    default-metric 10/)
      end
    end

    context 'novrf vrf' do
      before(:all) do
        @running_config = get_running_config('ospf | section "router ospf Sample"')
      end

      it 'has no configuration for the novrf vrf' do
        expect(@running_config).not_to match(/^novrf/)
      end
    end
  end

  describe 'cisco_package' do
    it 'installs a cisco-package' do
      expect(package('demo-one')).to be_installed
    end
  end

  describe 'cisco_snmp_community' do
    it 'sets the snmp community group' do
      expect(@running_config).to match(/^snmp-server community testcom group network-operator/)
    end

    it 'sets the snmp community ACL' do
      expect(@running_config).to match(/^snmp-server community testcom use-acl cookbook/)
    end

    it 'does not have a nocommunity community configured' do
      expect(@running_config).not_to match(/^snmp-server community nocommunity/)
    end
  end

  describe 'cisco_snmp_server' do
    it 'sets a contact 'do
      expect(@running_config).to match(/^snmp-server contact user1/)
    end

    it 'sets a location 'do
      expect(@running_config).to match(/^snmp-server location rtp/)
    end

    it 'sets a cache timeout 'do
      expect(@running_config).to match(/^snmp-server aaa-user cache-timeout 1000/)
    end

    it 'sets a packet size 'do
      expect(@running_config).to match(/^snmp-server packetsize 2500/)
    end

    it 'disables protocol 'do
      expect(@running_config).to match(/^no snmp-server protocol enable/)
    end

    it 'enables global enforce priv' do
      expect(@running_config).to match(/^snmp-server globalEnforcePriv/)
    end

    it 'disables tcp session auth' do
      expect(@running_config).to match(/^no snmp-server tcp-session auth/)
    end
  end

  describe 'cisco_snmp_user' do
    it 'configures the withengine user' do
      expect(@running_config).to match(/snmp-server user withengine auth md5 0x9fafd204728f5ccdb1cde2ca3f722863 priv 0x71be02b03d6ff0140cb6e9796f6d2ab4 localizedkey engineID 128:128:127:127:124:2/)
    end
  end

  describe 'cisco_tacacs_server' do
    it 'enables tacacs+' do
      expect(@running_config).to match(/^feature tacacs+/)
    end

    it 'sets the tacacs key' do
      expect(@running_config).to match(/^tacacs-server key 7 "wawy123"/)
    end

    it 'sets the source interface' do
      expect(@running_config).to match(/^ip tacacs source-interface Ethernet1\/1/)
    end

    it 'sets the timeout' do
      expect(@running_config).to match(/^tacacs-server timeout 1/)
    end

    it 'sets the deadtime' do
      expect(@running_config).to match(/^tacacs-server deadtime 20/)
    end

    it 'enables directed request' do
      expect(@running_config).to match(/^tacacs-server directed-request/)
    end
  end

  describe 'cisco_tacacs_server_host' do
    it 'configures the test host' do
      expect(@running_config).to match(/^tacacs-server host testhost key 7 "iksgsrkfkvgthz" port 66 timeout 1/)
    end
  end

  describe 'cisco_vlan' do
    before(:all) do
      @running_config = get_running_config('vlan 220')
    end

    it 'named the VLAN' do
      expect(@running_config).to match(/^  name cookbook/)
    end

    it 'is not shutdown' do
      expect(@running_config).not_to match(/shutdown/)
    end
  end

  describe 'cisco_vtp' do
    it 'enabled vtp' do
      expect(@running_config).to match(/^feature vtp/)
    end

    it 'configured the vtp domain' do
      expect(@running_config).to match(/^vtp domain cisco1234/)
    end
  end
end
