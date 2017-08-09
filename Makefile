PROJECT=encyc
APP=encycmw
USER=encyc

SHELL = /bin/bash
DEBIAN_CODENAME := $(shell lsb_release -sc)
DEBIAN_RELEASE := $(shell lsb_release -sr)
VERSION := $(shell cat VERSION)

GIT_SOURCE_URL=https://github.com/densho/encyc-mw

INSTALL_BASE=/opt
INSTALLDIR=$(INSTALL_BASE)/encyc-mw

CONF_BASE=/etc/encyc
CONF_PRODUCTION=$(CONF_BASE)/LocalSettings.php-1.24

NGINX_CONF=/etc/nginx/sites-available/encycmw.conf
NGINX_CONF_LINK=/etc/nginx/sites-enabled/encycmw.conf

FPM_BRANCH := $(shell git rev-parse --abbrev-ref HEAD | tr -d _ | tr -d -)
FPM_ARCH=amd64
FPM_NAME=$(APP)-$(FPM_BRANCH)
FPM_FILE=$(FPM_NAME)_$(VERSION)_$(FPM_ARCH).deb
FPM_VENDOR=Densho.org
FPM_MAINTAINER=<geoffrey.jost@densho.org>
FPM_DESCRIPTION=Encyclopedia Mediawiki
FPM_BASE=opt/encyc-mw


.PHONY: help

help:
	@echo "TODO encyc-mw install help"


# http://fpm.readthedocs.io/en/latest/
# https://stackoverflow.com/questions/32094205/set-a-custom-install-directory-when-making-a-deb-package-with-fpm
# https://brejoc.com/tag/fpm/
deb:
	@echo ""
	@echo "FPM packaging ----------------------------------------------------------"
	-rm -Rf $(FPM_FILE)
	fpm   \
	--verbose   \
	--input-type dir   \
	--output-type deb   \
	--name $(FPM_NAME)   \
	--version $(VERSION)   \
	--package $(FPM_FILE)   \
	--url "$(GIT_SOURCE_URL)"   \
	--vendor "$(FPM_VENDOR)"   \
	--maintainer "$(FPM_MAINTAINER)"   \
	--description "$(FPM_DESCRIPTION)"   \
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
	.git=$(FPM_BASE)   \
	.gitignore=$(FPM_BASE)   \
	conf=$(FPM_BASE)   \
	conf/LocalSettings.php-1.24=etc/encyc/LocalSettings.php-1.24   \
	conf/nginx.conf=etc/nginx/sites-available/encycmw.conf   \
	htdocs=$(FPM_BASE)   \
	INSTALL=$(FPM_BASE)   \
	Makefile=$(FPM_BASE)   \
	README.rst=$(FPM_BASE)   \
	VERSION=$(FPM_BASE)
