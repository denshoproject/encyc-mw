
PROJECT=encyc
APP=encycmw
USER=encyc
SHELL = /bin/bash

APP_VERSION := $(shell cat VERSION)
GIT_SOURCE_URL=https://github.com/densho/encyc-mw

# Release name e.g. jessie
DEBIAN_CODENAME := $(shell lsb_release -sc)
# Release numbers e.g. 8.10
DEBIAN_RELEASE := $(shell lsb_release -sr)
# Sortable major version tag e.g. deb8
DEBIAN_RELEASE_TAG = deb$(shell lsb_release -sr | cut -c1)

INSTALL_BASE=/opt
INSTALLDIR=$(INSTALL_BASE)/encyc-mw
IMAGES_DIR=$(INSTALLDIR)/htdocs/images

CONF_BASE=/etc/encyc
CONF_PRODUCTION=$(CONF_BASE)/LocalSettings.php-1.24

NGINX_CONF=/etc/nginx/sites-available/encycmw.conf
NGINX_CONF_LINK=/etc/nginx/sites-enabled/encycmw.conf

DEB_BRANCH := $(shell git rev-parse --abbrev-ref HEAD | tr -d _ | tr -d -)
DEB_ARCH=amd64
DEB_NAME_JESSIE=$(APP)-$(DEB_BRANCH)
DEB_NAME_STRETCH=$(APP)-$(DEB_BRANCH)
DEB_NAME_BUSTER=$(APP)-$(DEB_BRANCH)
# Application version, separator (~), Debian release tag e.g. deb8
# Release tag used because sortable and follows Debian project usage.
DEB_VERSION_JESSIE=$(APP_VERSION)~deb8
DEB_VERSION_STRETCH=$(APP_VERSION)~deb9
DEB_VERSION_BUSTER=$(APP_VERSION)~deb9
DEB_FILE_JESSIE=$(DEB_NAME_JESSIE)_$(DEB_VERSION_JESSIE)_$(DEB_ARCH).deb
DEB_FILE_STRETCH=$(DEB_NAME_STRETCH)_$(DEB_VERSION_STRETCH)_$(DEB_ARCH).deb
DEB_FILE_BUSTER=$(DEB_NAME_BUSTER)_$(DEB_VERSION_BUSTER)_$(DEB_ARCH).deb
DEB_VENDOR=Densho.org
DEB_MAINTAINER=<geoffrey.jost@densho.org>
DEB_DESCRIPTION=Encyclopedia Mediawiki
DEB_BASE=opt/encyc-mw


.PHONY: help

help:
	@echo "TODO encyc-mw install help"


install: install-prep install-app install-static install-configs

test: test-app

uninstall: uninstall-front

clean: clean-front


install-daemons: install-nginx

install-nginx:
	@echo ""
	@echo "Nginx ------------------------------------------------------------------"
	apt-get --assume-yes install nginx


install-app: install-encyc-mw

test-app: test-encyc-mw

uninstall-app: uninstall-encyc-mw

clean-app: clean-encyc-mw


install-encyc-mw:
	@echo ""
	@echo "encyc-mw --------------------------------------------------------------"
	apt-get --assume-yes install imagemagick libjpeg-turbo-progs memcached nginx php-pear php-cgi php-cli php-fpm php-mbstring php-mysql tidy
# images dir
	-mkdir $(IMAGES_DIR)
	chown -R root.www-data $(IMAGES_DIR)
	chmod 775 $(IMAGES_DIR)

test-encyc-mw:

uninstall-encyc-mw:
	apt-get --assume-yes remove imagemagick libjpeg-turbo-progs php-pear php-fpm php-mysql tidy

clean-encyc-mw:


install-configs:
	@echo ""
	@echo "installing configs ----------------------------------------------------"
# web app settings
	ln -s $(INSTALLDIR)/conf/LocalSettings.php-1.24 /opt/encyc-mw/htdocs/LocalSettings.php
# 	chown root.encyc /opt/encyc-mw/htdocs/LocalSettings.php-1.24
# 	chmod 640 /opt/encyc-mw/htdocs/LocalSettings.php-1.24

install-daemon-configs:
	@echo ""
	@echo "installing daemon configs ---------------------------------------------"
# php-fpm settings
	cp $(INSTALLDIR)/conf/www.conf /etc/php/7.3/fpm/pool.d/www.conf
	chown root.root /etc/php/7.3/fpm/pool.d/www.conf
	chmod 644 /etc/php/7.3/fpm/pool.d/www.conf
# nginx settings
	cp $(INSTALLDIR)/conf/nginx.conf /etc/nginx/sites-available/encycmw.conf
	chown root.root /etc/nginx/sites-available/encycmw.conf
	chmod 644 /etc/nginx/sites-available/encycmw.conf
	-ln -s /etc/nginx/sites-available/encycmw.conf /etc/nginx/sites-enabled/encycmw.conf
	-rm /etc/nginx/sites-enabled/default

uninstall-daemon-configs:
	-rm /etc/nginx/sites-available/encycmw.conf
	-rm /etc/nginx/sites-enabled/encycmw.conf


# http://fpm.readthedocs.io/en/latest/
install-fpm:
	@echo "install-fpm ------------------------------------------------------------"
	apt-get install --assume-yes ruby ruby-dev rubygems build-essential
	gem install --no-ri --no-rdoc fpm


# http://fpm.readthedocs.io/en/latest/
# https://stackoverflow.com/questions/32094205/set-a-custom-install-directory-when-making-a-deb-package-with-fpm
# https://brejoc.com/tag/fpm/
deb: deb-stretch

deb-stretch:
	@echo ""
	@echo "DEB packaging (stretch) ------------------------------------------------"
	-rm -Rf $(DEB_FILE_STRETCH)
	fpm   \
	--verbose   \
	--input-type dir   \
	--output-type deb   \
	--name $(DEB_NAME_STRETCH)   \
	--version $(DEB_VERSION_STRETCH)   \
	--package $(DEB_FILE_STRETCH)   \
	--url "$(GIT_SOURCE_URL)"   \
	--vendor "$(DEB_VENDOR)"   \
	--maintainer "$(DEB_MAINTAINER)"   \
	--description "$(DEB_DESCRIPTION)"   \
	--deb-recommends "mariadb-client"   \
	--deb-suggests "mariadb-server"   \
	--depends "imagemagick"   \
	--depends "libjpeg-turbo-progs"   \
	--depends "nginx"   \
	--depends "php-pear"   \
	--depends "php-cgi"   \
	--depends "php-cli"   \
	--depends "php-fpm"   \
	--depends "php-mysql"   \
	--depends "tidy"   \
	--chdir /opt/encyc-mw/   \
	.git=$(DEB_BASE)   \
	.gitignore=$(DEB_BASE)   \
	conf=$(DEB_BASE)   \
	htdocs=$(DEB_BASE)   \
	INSTALL=$(DEB_BASE)   \
	Makefile=$(DEB_BASE)   \
	README.rst=$(DEB_BASE)   \
	VERSION=$(DEB_BASE)

deb-buster:
	@echo ""
	@echo "DEB packaging (buster) -------------------------------------------------"
	-rm -Rf $(DEB_FILE_BUSTER)
	fpm   \
	--verbose   \
	--input-type dir   \
	--output-type deb   \
	--name $(DEB_NAME_BUSTER)   \
	--version $(DEB_VERSION_BUSTER)   \
	--package $(DEB_FILE_BUSTER)   \
	--url "$(GIT_SOURCE_URL)"   \
	--vendor "$(DEB_VENDOR)"   \
	--maintainer "$(DEB_MAINTAINER)"   \
	--description "$(DEB_DESCRIPTION)"   \
	--deb-recommends "mariadb-client"   \
	--deb-suggests "mariadb-server"   \
	--depends "imagemagick"   \
	--depends "libjpeg-turbo-progs"   \
	--depends "nginx"   \
	--depends "php-pear"   \
	--depends "php-cgi"   \
	--depends "php-cli"   \
	--depends "php-fpm"   \
	--depends "php-mysql"   \
	--depends "tidy"   \
	--chdir /opt/encyc-mw/   \
	.git=$(DEB_BASE)   \
	.gitignore=$(DEB_BASE)   \
	conf=$(DEB_BASE)   \
	htdocs=$(DEB_BASE)   \
	INSTALL=$(DEB_BASE)   \
	Makefile=$(DEB_BASE)   \
	README.rst=$(DEB_BASE)   \
	VERSION=$(DEB_BASE)
