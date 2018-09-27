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

CONF_BASE=/etc/encyc
CONF_PRODUCTION=$(CONF_BASE)/LocalSettings.php-1.24

NGINX_CONF=/etc/nginx/sites-available/encycmw.conf
NGINX_CONF_LINK=/etc/nginx/sites-enabled/encycmw.conf

DEB_BRANCH := $(shell git rev-parse --abbrev-ref HEAD | tr -d _ | tr -d -)
DEB_ARCH=amd64
DEB_NAME_JESSIE=$(APP)-$(DEB_BRANCH)
DEB_NAME_STRETCH=$(APP)-$(DEB_BRANCH)
# Application version, separator (~), Debian release tag e.g. deb8
# Release tag used because sortable and follows Debian project usage.
DEB_VERSION_JESSIE=$(APP_VERSION)~deb8
DEB_VERSION_STRETCH=$(APP_VERSION)~deb9
DEB_FILE_JESSIE=$(DEB_NAME_JESSIE)_$(DEB_VERSION_JESSIE)_$(DEB_ARCH).deb
DEB_FILE_STRETCH=$(DEB_NAME_STRETCH)_$(DEB_VERSION_STRETCH)_$(DEB_ARCH).deb
DEB_VENDOR=Densho.org
DEB_MAINTAINER=<geoffrey.jost@densho.org>
DEB_DESCRIPTION=Encyclopedia Mediawiki
DEB_BASE=opt/encyc-mw


.PHONY: help

help:
	@echo "TODO encyc-mw install help"


# http://fpm.readthedocs.io/en/latest/
# https://stackoverflow.com/questions/32094205/set-a-custom-install-directory-when-making-a-deb-package-with-fpm
# https://brejoc.com/tag/fpm/
deb: deb-stretch

# deb-jessie and deb-stretch are identical EXCEPT:
# jessie: --depends openjdk-7-jre
# stretch: --depends openjdk-8-jre
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
	--depends "php5-cgi"   \
	--depends "php5-cli"   \
	--depends "php5-fpm"   \
	--depends "php5-mysql"   \
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
