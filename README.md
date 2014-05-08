EpicDevBox
==========

Clean Laravel base box for Epic Stuff


What you'll need
================

1. Virtual box : https://www.virtualbox.org/
2. Vagrant : http://www.vagrantup.com/

Install
=======

1. In terminal, go to root directory of cloned repository (where Vagrantfile is located)
2. Type "Vagrant up"
3. Wait for Vagrant VM to boot. Laravel will then be installed and its database seeded.

Accessing the Virtual Machine - SSH
===================================

4. Accessing the VM: Type "Vagrant SSH" -> You are now controlling your Ubuntu VM via the command line
5. Laravel dir: "cd /var/www/webapp/laravel"
6. To find your VM's IP: Type "ifconfig" and take note of the ip address starting with "192.168"
7. Running Composer: Type "composer install". (only required on newly cloned repositories). If Composer is already installed, update Composer by typing "composer update".

Accessing the web server
========================

Point your browser to the address that you took note of when running ifconfig


Other info
==========

- After having updated Laravel, you might need to reinstall and update Composer
- When in guest machine, you can talk to host machine via 192.168.56.1
- Mysql Root account is u:root p:root

Note:
=====

If getting errors upon updating VirtualBox follow the following instructions:
http://kvz.io/blog/2013/01/16/vagrant-tip-keep-virtualbox-guest-additions-in-sync/

