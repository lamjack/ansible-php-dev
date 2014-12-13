# PHP Development Ansible playbook

This playbook installs the latest supported PHP versions plus the latest 5.3 release. It is aimed to help developers
which need to test their projects in different PHP versions (specially free or open source software developers).

This is done using [php-build][#php-build] (for building) and [phpenv][#phpenv] (to manage the installed versions).

It also:

- Install (build) the most recent ICU version, which is used to build the [`ext/intl` extension][#php-intl].
  Optionally, it can install older ICU releases down to the 4.0 release
- Build each PHP version with the latest ICU version or with all the installed ICU versions
- Optionally install Nginx
- PEAR is also installed as it is needed to have PECL

See the Usage section for information about daily usage.


## Requirements

- Ansible 1.2 or greater
- Debian Wheezy


## Role Variables

### icu role

####  `icu_build_releases`

One of the possible values: "all" or "latest".

If "all", the icu role will build all the ICU releases listed in the icu_releases variable. If "latest", it will
build only the latest ICU release listed in the icu_releases variable.

Defaults to `latest`.

#### `icu_path`

The path to install the ICU releases.

Defaults to `/opt/icu/versions`.

#### `icu_mirror_base_url`

ICU uses Source Forge to distribute its downloads.

Defaults to `http://www.mirrorservice.org/sites/download.sourceforge.net/pub/sourceforge/i/ic/icu/ICU4C`.

#### `icu_releases`

A list of ICU releases (dictionaries) to be compiled and installed. Attributes:

- version: required - the minor version specification (e.g. 4.0)
- url: required - the URL to the release gzip file in the icu-project.org website
- md5_checksum: required - the MD5 checksum of the gzip file (available on the icu-project.org website)
- patch_url: optional - a URL to a patch file to apply to the ICU source code

See the `roles/icu/defaults/main.yml` file for the default values.


### nginx role

#### `nginx_docroot_path`

The path to the Nginx document root.

Defaults to `/var/www`.


### php role

#### `install_nginx`

If true, installs Nginx.

Defaults to `true`.

####  `composer_path`

The global COMPOSER_HOME path.

See: https://getcomposer.org/doc/03-cli.md#composer-home

Defaults to `/opt/composer`.

#### `log_path`

The base path to store the log files.

Defaults to `/var/log`.

#### `php_log_path`

PHP log directory path.

Defaults to `{{ log_path }}/php`

#### `php_fpm_log_path`

PHP-FPM log directory path.

Defaults to `{{ log_path }}/php-fpm`

#### `php_build_releases`

One of the possible values: "all" or "latest".

If "all", the php role will build all the PHP releases listed in the php_releases variable. If "latest", it will
build only the latest PHP release listed in the php_releases variable.

Defaults to `latest`.

#### `php_icu_build_releases`

One of the possible values: "all" or "latest".

If "all", every PHP relase in php_releases will be build against the all the built ICU releases listed in the
icu_releases variable (see the icu role).

If "latest", every PHP relase in php_releases will be build against the latest built ICU release listed in the
icu_releases variable.

Defaults to `latest`.

#### `php_releases`

A list of PHP releases (dictionaries) to be compiled and installed. Attributes:

- version: required - the full version specification (e.g. 5.3.3)
- minor: required - used to make the versions comparisons
- ini_file: optional - which php.ini file to use, "development" or "production", defaults to "development"

This list must be ordered from oldest to newest version by convention. See php_build_releases.

If php_icu_build_releases is equal to "latest", it will create a symlink from the minor to the version value in the
phpenv_versions_path directory, just to simplify the usage of phpenv local and global commands:

    $ phpenv versions
      5.6
    * 5.6.3 (set by /opt/phpenv/version)

    $ phpenv local 5.6

    $ phpenv versions
    * 5.6 (set by /home/vagrant/.php-version)
      5.6.3

See the `roles/php/defaults/main.yml` file for the default values.

#### `php_ini_configuration`

A dictionary of PHP configuration directives. These overrides the default values in the php.ini file and are stored
in the phpenv_versions_path/<php-version>/etc/conf.d/php-configuration.ini file.

php.ini sections are not supported.

See: http://php.net/manual/en/ini.list.php
See: http://php.net/manual/en/ini.core.php

It sets the `error_log` directive to `{{ php_log_path }}/error.log`.

See the `roles/php/defaults/main.yml` file for the other default values.

#### `php_fpm_configuration`

A dictionary of PHP-FPM configuration directives. These overrides the default values in the php.ini file and are
stored in the phpenv_versions_path/<php-version>/etc/fpm.conf.d/php-fpm-configuration.ini file.

See: http://php.net/manual/en/install.fpm.configuration.php

It sets the `error_log` directive to `{{ php_fpm_log_path }}/error.log`.

#### `php_fpm_pools`

A list with the name of the PHP-FPM pools.

The www pool must exists as we are using the default php-fpm.conf file.

#### `php_fpm_configuration`

A dictionary of dictionaries with the specific configuration for each pool in php_fpm_pools.

It sets the `group` and `user` directives for the `www` pool to `www-data`.

See the `roles/php/defaults/main.yml` file for the other default values.

#### `php_pecl_extensions`

A list of PECL extensions (dictionaries) desired to be installed. Attributes:

- name: required - the name of the extension as listed in pecl.php.net
- version: optional - the specific version to install, defaults to "stable"
- alias: optional - some extensions use another name to build the shared object file. ZendOpcache, for example,
    build a opcache.so file. Use this attribute for these cases
- zend_extension: optional - set to true if the extension is a Zend extension, otherwise the extension will not load
    properly. Defaults to false
- php_version: optional - only install if the PHP version comparison pass for this value. Defaults to the latest
    release listed in php_releases
- php_comparison: optional - a comparison operator used to compare against php_version. Defaults to "<=".
    available comparison operators in: http://docs.ansible.com/playbooks_variables.html#version-comparison-filters

See the `roles/php/defaults/main.yml` file for the default values.

#### `php_pecl_build_librabbitmq`

If true, build librabbitmq. If you're installing a packaged version of it or isn't installing the PECL amqp package,
set it to false.

Defaults to `true`.

#### `composer_packages`

A list of packages to be installed globally with Composer.

See the `roles/php/defaults/main.yml` file for the default values.

#### `composer_clean_cache`

If true, clean up the Composer cache after installing the packages.

Defaults to `false`.

### phpbuild role

#### `phpbuild_repositories`

The php-build and phpenv project repositories.

See the `roles/phpbuild/defaults/main.yml` file for the default values.

#### `phpbuild_path`

php-build installation path.

Defaults to `/opt/php-build`.

#### `phpenv_path`

phpenv installation path.

Defaults to `/opt/phpenv`.

#### `phpenv_versions_path`

Just for code clarity, the path to the phpenv's versions directory.

Defaults to `{{ phpenv_path }}/versions`.


## Dependencies

None.


## Example Playbook

    - hosts: all

      roles:
      - php

      # This will build the latest PHP release with all the available ICU releases down to the 4.0 version.
      vars:
      - php_build_releases: latest
      - php_icu_build_releases: all


## Important Role Variables For ansible-playbook

The most important role variables to use as "extra vars" with `ansible-playbook` are:

- `icu_build_releases`: build "latest" or "all" ICU releases
- `install_nginx`: install Nginx
- `php_build_releases`: build "latest" or "all" PHP releases
- `php_icu_build_releases`: build PHP with "latest" installed ICU release or with "all" installed ICU releases

See the Vagrant Testing section for practical usage examples.


## Vagrant Testing

This playbook ships with a Vagrantfile for testing purposes, using the [chef/debian](https://github.com/opscode/bento)
Vagrant box:

    $ vagrant up
    $ ansible-playbook -i inventories/vagrant -s site.yml

To build all the available PHP releases:

    $ ansible-playbook -i inventories/vagrant -s site.yml -e "php_build_releases=all"

To build all the available ICU and PHP releases, building PHP against all the installed ICU releases (wait longer hours!):

    $ ansible-playbook -i inventories/vagrant -s site.yml -e "icu_build_releases=all php_build_releases=all php_icu_build_releases=all"

To disable Nginx building:

    $ ansible-playbook -i inventories/vagrant -s site.yml -e "install_nginx=false"


## PHP Information

### PHP-FPM

PHP-FPM is installed for each PHP version. To start it with Nginx, use the helper command `webserver`. See the Usage
section.


### PHP Extensions

Each PHP version is built with the following extensions:

- amqp
- bcmath
- Core
- ctype
- curl
- date
- dom
- ereg
- exif
- fileinfo
- filter
- ftp
- gd
- hash
- iconv
- igbinary
- intl
- json
- libxml
- mbstring
- mcrypt
- memcached
- mongo
- mysql
- mysqli
- mysqlnd
- openssl
- pcntl
- pcre
- PDO
- pdo_mysql
- pdo_pgsql
- pdo_sqlite
- Phar
- posix
- readline
- Reflection
- riak
- session
- shmop
- SimpleXML
- soap
- sockets
- SPL
- sqlite3
- standard
- sysvsem
- sysvshm
- tidy
- tokenizer
- xdebug
- xml
- xmlreader
- xmlrpc
- xmlwriter
- xsl
- Zend OPcache
- zip
- zlib

From the previous list, the following extensions were installed using PECL:

- [amqp][#php-amqp]
- [igbinary][#php-igbinary]
- [memcached][#php-memcached]
- [mongo][#php-mongo]
- [riak][#php-riak]
- [xdebug][#php-xdebug]
- [Zend OPcache][#php-opcache] (PHP < 5.5)


### Composer

Composer is also installed. The following libraries are installed globally:

- [Behat][#behat]
- [PHP Coding Standards Fixer][#php-cs-fixer]
- [PHP_Depend][#phpdepend]
- [PHPLOC][#phploc]
- [PHPMD][#phpmd]
- [PHPUnit][#phpunit]
- [PHPCPD][#phpcpd]
- [PHP_CodeSniffer][#phpcodesniffer]
- [phpDox][#phpdox]


## Usage

You'll use the `phpenv` command basically to switch between the installed PHP versions:

    $ phpenv versions
      5.3
      5.3.29
      5.4
      5.4.35
      5.5
      5.5.19
      5.6
    * 5.6.3 (set by /opt/phpenv/version)

5.6, 5.5, 5.4 and 5.3 are just shortcuts. `phpenv` let you define the global and local PHP version. To set it 
globally (root privileges are needed):

    $ sudo -i phpenv global 5.5

To set a local version, use:

    $ phpenv local 5.4

To install additional PHP libraries globally with Composer, you'll need root privileges:

    $ sudo composer global require fabpot/php-cs-fixer:dev-master

You can start the Nginx and PHP-FPM using the helper command `webserver` (which are not installed as services, root privileges are needed):

    $ sudo webserver start
    Starting PHP-FPM (PHP version 5.6.3) server.
    Starting Nginx server.
    Done.

The Zend OPCache is enabled by default. If you want to disable it, you can run the helper command `opcache` (root
privileges are needed):

    $ sudo opcache disable
    The Zend OPCache (PHP version 5.6.3) was disabled.

    You need to restart the webserver for the changes to take effect.
    Execute: webserver restart


## Improvements

- Decouple the ICU version from the PHP version name in the `php` role, which makes the code unreadable. The idea is to
  create a helper script to create proper Ansible variables and php-build definition files
- Support other Debian releases and Ubuntu
- Tagging


## License

Apache License 2.0


## Author Information

[Eriksen Costa](http://blog.eriksen.com.br)


[#php-build]: https://github.com/CHH/php-build
[#phpenv]: https://github.com/CHH/phpenv
[#php-intl]: http://php.net/intl
[#php-amqp]: http://pecl.php.net/package/amqp
[#php-igbinary]: http://pecl.php.net/package/igbinary
[#php-memcached]: http://pecl.php.net/package/memcached
[#php-mongo]: http://pecl.php.net/package/mongo
[#php-riak]: http://pecl.php.net/package/riak
[#php-xdebug]: http://pecl.php.net/package/xdebug
[#php-opcache]: http://pecl.php.net/package/ZendOpcache
[#behat]: http://behat.org
[#php-cs-fixer]: http://cs.sensiolabs.org
[#phpdepend]: http://pdepend.org
[#phploc]: https://github.com/sebastianbergmann/phploc
[#phpmd]: http://phpmd.org
[#phpunit]: https://phpunit.de
[#phpcpd]: https://github.com/sebastianbergmann/phpcpd
[#phpcodesniffer]: https://github.com/squizlabs/PHP_CodeSniffer
[#phpdox]: http://phpdox.de
