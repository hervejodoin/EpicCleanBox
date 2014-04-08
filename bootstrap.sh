#!/usr/bin/env bash

# Update apt
apt-get -y update

# As per: http://www.dev-metal.com/how-to-setup-latest-version-of-php-5-5-on-ubuntu-12-04-lts/
apt-get install -y python-software-properties

# Get repository for PHP 5-Stable - As per: http://www.dev-metal.com/how-to-setup-latest-version-of-php-5-5-on-ubuntu-12-04-lts/
add-apt-repository -y ppa:ondrej/php5-oldstable

# Update apt - Repeat As per: http://www.dev-metal.com/how-to-setup-latest-version-of-php-5-5-on-ubuntu-12-04-lts/
apt-get -y update

# Install requirements
apt-get install -y apache2

#As per: http://www.dev-metal.com/how-to-setup-latest-version-of-php-5-5-on-ubuntu-12-04-lts/
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install php5

#Continue Install requirements
apt-get install -y php5-cli
apt-get install -y php5-mcrypt
apt-get install -y php5-gd
apt-get install -y php-apc
apt-get install -y git
apt-get install -y sqlite
apt-get install -y php5-sqlite
apt-get install -y curl
apt-get install -y php5-curl
apt-get install -y php5-xdebug
apt-get install -y php5-imagick4
apt-get install -y php5-imagick
apt-get install -y graphicsmagick libgraphicsmagick1-dev
apt-get install -y msmtp ca-certificates vim-nox

# Install MySQL
sudo debconf-set-selections <<< 'mysql-server-<version> mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server-<version> mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server

# If phpmyadmin does not exist, install it
if [ ! -f /etc/phpmyadmin/config.inc.php ];
then

    # Used debconf-get-selections to find out what questions will be asked
    # This command needs debconf-utils

    # Handy for debugging. clear answers phpmyadmin: echo PURGE | debconf-communicate phpmyadmin

    echo 'phpmyadmin phpmyadmin/dbconfig-install boolean false' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections

    echo 'phpmyadmin phpmyadmin/app-password-confirm password root' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/mysql/admin-pass password root' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/password-confirm password root' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/setup-password password root' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/database-type select mysql' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/mysql/app-pass password root' | debconf-set-selections

    echo 'dbconfig-common dbconfig-common/mysql/app-pass password root' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/mysql/app-pass password' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/password-confirm password root' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/app-password-confirm password root' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/app-password-confirm password root' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/password-confirm password root' | debconf-set-selections

    apt-get -y install phpmyadmin
fi


# Setup hosts file
VHOST=$(cat <<EOF
    <VirtualHost *:80>
            ServerAdmin webmaster@localhost

            DocumentRoot /var/www/webapp/laravel/public/
            Alias /webgrind /var/www/webgrind
            <Directory />
                    Options FollowSymLinks
                    AllowOverride All
            </Directory>
            <Directory /var/www/webapp/>
                    Options Indexes FollowSymLinks MultiViews
                    AllowOverride All
                    Order allow,deny
                    allow from all
            </Directory>
            DirectoryIndex index.php
            ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
            <Directory "/usr/lib/cgi-bin">
                    AllowOverride None
                    Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                    Order allow,deny
                    Allow from all
            </Directory>
    </VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/default

# Configure MSMTP
MSMTP=$(cat <<EOF
# ------------------------------------------------------------------------------
# msmtp System Wide Configuration file
# ------------------------------------------------------------------------------

# A system wide configuration is optional.
# If it exists, it usually defines a default account.
# This allows msmtp to be used like /usr/sbin/sendmail.

# ------------------------------------------------------------------------------
# Accounts
# ------------------------------------------------------------------------------

# Main Account
defaults
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account default
host smtp.mailgun.org
port 25
auth on
from dev@epicatomic.mailgun.org
user postmaster@epicatomic.mailgun.org
password 1ca47w6l6ye4
logfile /var/log/msmtp.log

# ------------------------------------------------------------------------------
# Configurations
# ------------------------------------------------------------------------------

# Construct envelope-from addresses of the form "user@oursite.example".
#auto_from on
#maildomain fermmy.server

# Use TLS.
#tls on
#tls_trust_file /etc/ssl/certs/ca-certificates.crt

# Syslog logging with facility LOG_MAIL instead of the default LOG_USER.
# Must be done within "account" sub-section above
#syslog LOG_MAIL

# Set a default account

# ------------------------------------------------------------------------------
EOF
)
echo "${MSMTP}" > /etc/msmtprc

# Configure PHP to use MSMTP
sudo sed -i "s[^;sendmail_path =.*[sendmail_path = '/usr/bin/msmtp -t'[g" /etc/php5/apache2/php.ini

# Configure XDebug
XDEBUG=$(cat <<EOF
;zend_extension=/usr/lib/php5/20100525/xdebug.so
xdebug.default_enable=1
xdebug.profiler_enable=1
xdebug.profiler_output_dir="/tmp"
xdebug.profiler_append=0
xdebug.profiler_output_name="cachegrind.out.%t.%p"
xdebug.idekey="macgdbp"
xdebug.var_display_max_children=999
xdebug.var_display_max_data=99999
xdebug.var_display_max_depth=100
xdebug.remote_log="/tmp/xdebug.log"
xdebug.remote_enable = 1
xdebug.remote_host = "192.168.56.1"
xdebug.remote_port = 9000
xdebug.remote_handler = "dbgp"
xdebug.remote_mode = req
xdebug.remote_connect_back = 1
EOF
)
echo "${XDEBUG}" > /etc/php5/conf.d/xdebug.ini

# Install webgrind if not already present
if [ ! -d /var/www/webgrind ];
then
    git clone https://github.com/jokkedk/webgrind.git /var/www/webgrind
fi

# Install Composer
# ----------------
curl -s https://getcomposer.org/installer | php
# Make Composer available globally
mv composer.phar /usr/local/bin/composer

# Enable mod_rewrite
sudo a2enmod rewrite

# Set timezone in php.ini
sed -i '$ a\date.timezone = "America/Montreal"' /etc/php5/apache2/php.ini

# Restart Apache
sudo service apache2 restart

# Create the BVL database
mysql -uroot -proot < /var/www/webapp/sql/setup.sql

# Change permission on Laravel storage folder

    Echo "Changing permission on Laravel storage folder"
    cd /var/www/webapp/laravel/app
    chmod -Rvc 777 storage

# Laravel stuff
# -------------

# Load Composer packages

    cd /var/www/webapp/laravel
    composer install

# Calling ifcongig to display public network IP

    Echo "Calling ifconfig"
    ifconfig
