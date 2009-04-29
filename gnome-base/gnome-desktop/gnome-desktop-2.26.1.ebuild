# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-desktop/gnome-desktop-2.24.3.ebuild,v 1.1 2009/01/13 23:18:48 remi Exp $

EAPI="2"

inherit eutils gnome2 multilib-native

DESCRIPTION="Libraries for the gnome desktop that are not part of the UI"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 FDL-1.1 LGPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc"

# FIXME: Python deps are needed for gnome-about but not
# listed in configure.ac
RDEPEND=">=x11-libs/gtk+-2.14.0[lib32?]
	>=dev-libs/glib-2.19.1[lib32?]
	>=x11-libs/libXrandr-1.2[lib32?]
	>=gnome-base/gconf-2[lib32?]
	>=x11-libs/startup-notification-0.5[lib32?]
	>=dev-python/pygtk-2.8
	>=dev-python/pygobject-2.14
	>=dev-python/libgnome-python-2.22"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.9
	>=app-text/gnome-doc-utils-0.3.2
	doc? ( >=dev-util/gtk-doc-1.4 )
	~app-text/docbook-xml-dtd-4.1.2
	x11-proto/xproto
	>=x11-proto/randrproto-1.2"
# Includes X11/Xatom.h in libgnome-desktop/gnome-bg.c which comes from xproto
# Includes X11/extensions/Xrandr.h that includes randr.h from randrproto (and
# eventually libXrandr shouldn't RDEPEND on randrproto)

DOCS="AUTHORS ChangeLog HACKING NEWS README"

pkg_setup() {
	G2CONF="${G2CONF} --with-gnome-distributor=Gentoo --disable-scrollkeeper"
}

pkg_postinst() {
	ewarn
	ewarn "If you are upgrading from <gnome-base/gnome-desktop-2.25, please"
	ewarn "make sure you run revdep-rebuild at the end of the upgrade."
}