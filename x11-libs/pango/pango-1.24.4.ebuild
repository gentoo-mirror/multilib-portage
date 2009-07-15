# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/pango/pango-1.24.4.ebuild,v 1.1 2009/07/09 11:28:49 mrpouet Exp $

EAPI="2"

inherit eutils gnome2 multilib multilib-native

DESCRIPTION="Text rendering and layout library"
HOMEPAGE="http://www.pango.org/"

LICENSE="LGPL-2 FTL"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="X debug"

# FIXME: add gobject-introspection dependency when it is available
RDEPEND="dev-libs/glib:2[lib32?]
	>=media-libs/fontconfig-2.5.0[lib32?]
	media-libs/freetype:2[lib32?]
	>=x11-libs/cairo-1.7.6[lib32?]
	X? (
		x11-libs/libXrender[lib32?]
		x11-libs/libX11[lib32?]
		x11-libs/libXft[lib32?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? (
		>=dev-util/gtk-doc-1
		~app-text/docbook-xml-dtd-4.1.2 )
	X? ( x11-proto/xproto )"

DOCS="AUTHORS ChangeLog* NEWS README THANKS"

function multilib_enabled() {
	has_multilib_profile || ( use x86 && [ "$(get_libdir)" = "lib32" ] )
}

pkg_setup() {
	G2CONF="${G2CONF} $(use_with X x)"
}

src_prepare() {
	gnome2_src_prepare

	# make config file location host specific so that a 32bit and 64bit pango
	# wont fight with each other on a multilib system.  Fix building for
	# emul-linux-x86-gtklibs
	if multilib_enabled ; then
		epatch "${FILESDIR}/${PN}-1.2.5-lib64.patch"
	fi

	# gtk-doc checks do not pass, upstream bug #578944
	sed 's:TESTS = check.docs: TESTS = :g'\
		-i docs/Makefile.am docs/Makefile.in || die "sed failed"
	sed -e '/@cd "$(DESTDIR)$(man1dir)" && gzip -c pango-view.1 > preload.1.gz && $(RM) preload.1/d' -i pango-view/Makefile.{in,am} || die 
}

multilib-native_src_configure_internal() {
	local myconf

	if use debug ; then
		myconf="--enable-debug=yes"
	fi

	econf $(use_with X x) ${myconf} || die
}

multilib-native_src_install_internal() {
	gnome2_src_install
	rm -f "${D}/etc/pango/${CHOST}/pango.modules" || die "rm pango.modules failed"

	prep_ml_binaries /usr/bin/pango-querymodules
}

multilib-native_pkg_postinst_internal() {
	if [ "${ROOT}" = "/" ] ; then
		einfo "Generating modules listing..."

		local PANGO_CONFDIR=

		if multilib_enabled ; then
			PANGO_CONFDIR="/etc/pango/${CHOST}"
		else
			PANGO_CONFDIR="/etc/pango"
		fi

		mkdir -p ${PANGO_CONFDIR}

		pango-querymodules > ${PANGO_CONFDIR}/pango.modules
	fi
}