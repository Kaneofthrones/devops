# -*- mode: ruby -*-
# vi: set ft=ruby :

required_plugins = %w( vagrant-hostsupdater vagrant-berkshelf )
required_plugins.each do |plugin|
    exec "vagrant plugin install #{plugin};vagrant #{ARGV.join(" ")}" unless Vagrant.has_plugin? plugin || ARGV[0] == 'plugin'
end

Vagrant.configure("2") do |config|

	config.vm.define "web" do |web|

  	web.vm.box = "ubuntu/xenial64"
  	web.vm.network "private_network", ip: "192.168.10.100"
  	web.hostsupdater.aliases = ["development.local"]
  	web.vm.synced_folder ".", "/home/ubuntu/app"

    #provisioning
  	web.vm.provision "shell", path: "environment/web/provision.sh"
    web.vm.provision "shell", inline: 'echo "export DB_HOST=mongodb://192.168.10.200/posts" >> .bashrc'
    web.vm.provision "chef_solo" do |chef|
      chef.run_list = ["recipe[web::default]"]
    end
  end


  config.vm.define "db" do |db|

  	db.vm.box = "ubuntu/xenial64"
    db.vm.network "private_network", ip: "192.168.10.200"
  	db.hostsupdater.aliases = ["database.local"]
  	db.vm.synced_folder ".", "/home/ubuntu/app"
  	db.vm.provision "shell", path: "environment/db/mongodb.sh"
    db.vm.provision "chef_solo" do |chef|
      chef.run_list = ["recipe[db::default]"]
    end
  end

end
