# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gnutls/gnutls-2.4.1-r2.ebuild,v 1.2 2008/11/18 11:56:26 dragonheart Exp $

EAPI="2"

inherit libtool eutils multilib-native

DESCRIPTION="A TLS 1.0 and SSL 3.0 implementation for the GNU project"
HOMEPAGE="http://www.gnutls.org/"
SRC_URI="http://www.gnu.org/software/gnutls/releases/${P}.tar.bz2"
#SRC_URI="mirror://gnu/gnutls/${P}.tar.bz2"

# GPL-3 for the gnutls-extras library and LGPL for the gnutls library.
LICENSE="LGPL-2.1 GPL-3"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="zlib lzo doc nls guile bindist"

RDEPEND="dev-libs/libgpg-error[lib32?]
	>=dev-libs/libgcrypt-1.2.4[lib32?]
	>=dev-libs/libtasn1-0.3.4[lib32?]
	nls? ( virtual/libintl )
	guile? ( dev-scheme/guile )
	zlib? ( >=sys-libs/zlib-1.1[lib32?] )
	!bindist? ( lzo? ( >=dev-libs/lzo-2 ) )"
DEPEND="${RDEPEND}
	sys-devel/libtool
	doc? ( dev-util/gtk-doc )
	nls? ( sys-devel/gettext )"

pkg_setup() {
	if use guile && ! built_with_use dev-scheme/guile networking; then
		eerror "You are trying to compile ${PN} package with USE=\"guile\""
		eerror "while dev-scheme/guile does not have USE=\"networking\""
		die
	fi
	if use lzo && use bindist; then
		ewarn "lzo support was disabled for binary distribution of gnutls"
		ewarn "due to licensing issues. See Bug 202381 for details."
		epause 5
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.3.11+gcc-4.3.patch
	epatch "${FILESDIR}"/gnutls-2.2.5-CVE-2008-4989-V2.patch

	elibtoolize # for sane .so versioning on FreeBSD
}

multilib-native_src_configure_internal() {
	if use lib32 && [[ "${ABI}" == "x86" ]]; then
		export LIBGCRYPT_CONFIG="/usr/bin/libgcrypt-config32"
		export LIBTASN1_CONFIG="/usr/bin/libtasn1-config32"
	else
		export LIBGCRYPT_CONFIG="/usr/bin/libgcrypt-config"
		export LIBTASN1_CONFIG="/usr/bin/libtasn1-config"
	fi

	local myconf
	use bindist && myconf="--without-lzo" || myconf="$(use_with lzo)"
	econf  \
		$(use_with zlib) \
		$(use_enable nls) \
		$(use_enable guile) \
		$(use_enable doc gtk-doc) \
		${myconf}
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog NEWS \
		README THANKS doc/TODO

	if use doc ; then
		dodoc doc/README.autoconf doc/tex/gnutls.ps
		docinto examples
		dodoc doc/examples/*.c
	fi
}
