# Devops
Development environment setup

<hr>

* Install VirtualBox
	* [Download VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Install Vagrant
	[Download Vagrant](https://www.vagrantup.com/downloads.html)
	
	
<hr> 

### Build a Box

You’ll need a project to work on, and a development environment configuration. For this we will use github, you can create your own repository or clone mine for testing purposes here: [github link](git@github.com:Kaneofthrones/devops.git)
(if you need help with github, you can find the docs here: [Git Docs](https://git-scm.com/documentation)

<hr>


To power up your custom VM run the command `vagrant up` in your terminal (can take a while if it is your first time running this command)

<hr>

Once the VM is up, type the following command `vagrant ssh` 

<hr>

In the terminal update the operating system by running the following command: `sudo apt-get update -y`

<hr>

Now we need to install nginx by running the command `sudo apt-get install nginx`

<hr>

then type `development.local` into your browser to test the server is running 