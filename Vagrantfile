Vagrant.configure(2) do |config|
  boxes = [
    { :name => "devubu20", :box => "generic/ubuntu2010", :ip => "192.168.0.2" },
    { :name => "devcnt7",  :box => "generic/centos7",    :ip => "192.168.0.3" },
    { :name => "devcnt6",  :box => "generic/centos6",    :ip => "192.168.0.4" }    
  ]
    
###
# Linux Test Box Generation
###
  boxes.each { |opts|
    config.vm.define opts[:name] do |dev|
      config.vm.synced_folder ".", "/opt", disabled: false
      dev.vm.box = opts[:box]      
      dev.vm.provision "shell", path: "scripts/base_install.sh"
      dev.vm.provision "shell", privileged: false, path: "scripts/ansible_bootstrap.rb"
      # dev.vm.provision "ansible" do |ansible|
      #   ansible.playbook = "site.yml"
      # end
      dev.vm.provision :serverspec do |spec|
        # pattern for specfiles to search
        spec.pattern = '*_spec.rb'
        # pattern for specfiles to ignore, similar to rspec's --exclude-pattern option
        spec.exclude_pattern = 'but_not_*_spec.rb'
      end
      dev.vm.network "private_network", ip: opts[:ip]
      dev.vm.hostname = opts[:name]
    end
  }


end