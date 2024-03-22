
PROJECT=encyc
APP=encycmw
USER=encyc
SHELL = /bin/bash

APP_VERSION := $(shell cat VERSION)
GIT_SOURCE_URL=https://github.com/densho/encyc-mw

PHP_VERSION=7.4
ifeq ($(DEBIAN_CODENAME), buster)
	PHP_VERSION=7.3
endif

INSTALL_BASE=/opt
INSTALLDIR=$(INSTALL_BASE)/encyc-mw
IMAGES_DIR=$(INSTALLDIR)/htdocs/images

CONF_BASE=/etc/encyc
CONF_PRODUCTION=$(CONF_BASE)/LocalSettings.php

NGINX_CONF=/etc/nginx/sites-available/encycmw.conf
NGINX_CONF_LINK=/etc/nginx/sites-enabled/encycmw.conf

# Release name e.g. jessie
DEBIAN_CODENAME := $(shell lsb_release -sc)
# Release numbers e.g. 8.10
DEBIAN_RELEASE := $(shell lsb_release -sr)
# Sortable major version tag e.g. deb8
DEBIAN_RELEASE_TAG = deb$(shell lsb_release -sr | cut -c1)

TGZ_BRANCH := $(shell python3 bin/package-branch.py)
TGZ_FILE=$(APP)_$(APP_VERSION)
TGZ_DIR=$(INSTALLDIR)/$(TGZ_FILE)
TGZ_MW=$(TGZ_DIR)/encyc-mw

# Adding '-rcN' to VERSION will name the package "ddrlocal-release"
# instead of "ddrlocal-BRANCH"
DEB_BRANCH := $(shell python3 bin/package-branch.py)
DEB_ARCH=amd64
DEB_NAME_BULLSEYE=$(APP)-$(DEB_BRANCH)
DEB_NAME_BOOKWORM=$(APP)-$(DEB_BRANCH)
DEB_NAME_TRIXIE=$(APP)-$(DEB_BRANCH)
# Application version, separator (~), Debian release tag e.g. deb8
# Release tag used because sortable and follows Debian project usage.
DEB_VERSION_BULLSEYE=$(APP_VERSION)~deb11
DEB_VERSION_BOOKWORM=$(APP_VERSION)~deb12
DEB_VERSION_TRIXIE=$(APP_VERSION)~deb13
DEB_FILE_BULLSEYE=$(DEB_NAME_BULLSEYE)_$(DEB_VERSION_BULLSEYE)_$(DEB_ARCH).deb
DEB_FILE_BOOKWORM=$(DEB_NAME_BOOKWORM)_$(DEB_VERSION_BOOKWORM)_$(DEB_ARCH).deb
DEB_FILE_TRIXIE=$(DEB_NAME_TRIXIE)_$(DEB_VERSION_TRIXIE)_$(DEB_ARCH).deb
DEB_VENDOR=Densho.org
DEB_MAINTAINER=<geoffrey.jost@densho.org>
DEB_DESCRIPTION=Encyclopedia Mediawiki
DEB_BASE=opt/encyc-mw


.PHONY: help

help:
	@echo "TODO encyc-mw install help"


install: install-app install-configs

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
	chown -R www-data:www-data $(IMAGES_DIR)
	chmod 775 $(IMAGES_DIR)

test-encyc-mw:

uninstall-encyc-mw:
	apt-get --assume-yes remove imagemagick libjpeg-turbo-progs php-pear php-fpm php-mysql tidy

clean-encyc-mw:


install-configs:
	@echo ""
	@echo "installing configs ----------------------------------------------------"
# web app settings
	-mkdir $(CONF_BASE)
	ln -s $(CONF_PRODUCTION) /opt/encyc-mw/htdocs/LocalSettings.php
# 	chown root.encyc /opt/encyc-mw/htdocs/LocalSettings.php
# 	chmod 640 /opt/encyc-mw/htdocs/LocalSettings.php

install-daemon-configs:
	@echo ""
	@echo "installing daemon configs ---------------------------------------------"
# php-fpm settings
	cp $(INSTALLDIR)/conf/www.conf /etc/php/$(PHP_VERSION)/fpm/pool.d/www.conf
	chown root.root /etc/php/$(PHP_VERSION)/fpm/pool.d/www.conf
	chmod 644 /etc/php/$(PHP_VERSION)/fpm/pool.d/www.conf
# nginx settings
	cp $(INSTALLDIR)/conf/nginx.conf /etc/nginx/sites-available/encycmw.conf
	chown root.root /etc/nginx/sites-available/encycmw.conf
	chmod 644 /etc/nginx/sites-available/encycmw.conf
	-ln -s /etc/nginx/sites-available/encycmw.conf /etc/nginx/sites-enabled/encycmw.conf
	-rm /etc/nginx/sites-enabled/default

uninstall-daemon-configs:
	-rm /etc/nginx/sites-available/encycmw.conf
	-rm /etc/nginx/sites-enabled/encycmw.conf


tgz-local:
	rm -Rf $(TGZ_DIR)
	git clone $(INSTALLDIR) $(TGZ_MW)
	cd $(TGZ_MW); git checkout develop; git checkout master
	tar czf $(TGZ_FILE).tgz $(TGZ_FILE)
	rm -Rf $(TGZ_DIR)

tgz:
	rm -Rf $(TGZ_DIR)
	git clone $(GIT_SOURCE_URL) $(TGZ_MW)
	cd $(TGZ_MW); git checkout develop; git checkout master
	tar czf $(TGZ_FILE).tgz $(TGZ_FILE)
	rm -Rf $(TGZ_DIR)


# http://fpm.readthedocs.io/en/latest/
install-fpm:
	@echo "install-fpm ------------------------------------------------------------"
	apt-get install --assume-yes ruby ruby-dev rubygems build-essential
	gem install --no-document fpm

# https://stackoverflow.com/questions/32094205/set-a-custom-install-directory-when-making-a-deb-package-with-fpm
# https://brejoc.com/tag/fpm/
deb: deb-bullseye

deb-bullseye:
	@echo ""
	@echo "FPM packaging (bullseye) -----------------------------------------------"
	-rm -Rf $(DEB_FILE_BULLSEYE)
# Make package
	fpm   \
	--verbose   \
	--input-type dir   \
	--output-type deb   \
	--name $(DEB_NAME_BULLSEYE)   \
	--version $(DEB_VERSION_BULLSEYE)   \
	--package $(DEB_FILE_BULLSEYE)   \
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

deb-bookworm:
	@echo ""
	@echo "FPM packaging (bookworm) -----------------------------------------------"
	-rm -Rf $(DEB_FILE_BOOKWORM)
# Make package
	fpm   \
	--verbose   \
	--input-type dir   \
	--output-type deb   \
	--name $(DEB_NAME_BOOKWORM)   \
	--version $(DEB_VERSION_BOOKWORM)   \
	--package $(DEB_FILE_BOOKWORM)   \
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
	--depends "php-mbstring"   \
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

deb-trixie:
	@echo ""
	@echo "FPM packaging (trixie) -----------------------------------------------"
	-rm -Rf $(DEB_FILE_TRIXIE)
# Make package
	fpm   \
	--verbose   \
	--input-type dir   \
	--output-type deb   \
	--name $(DEB_NAME_TRIXIE)   \
	--version $(DEB_VERSION_TRIXIE)   \
	--package $(DEB_FILE_TRIXIE)   \
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
	--depends "php-mbstring"   \
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
