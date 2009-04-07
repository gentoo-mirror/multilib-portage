# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libdc1394/libdc1394-2.0.3.ebuild,v 1.1 2009/01/31 10:54:58 stefaan Exp $

EAPI="2"

inherit eutils multilib-native

DESCRIPTION="Library to interface with IEEE 1394 cameras following the IIDC specification"
HOMEPAGE="http://sourceforge.net/projects/libdc1394/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="X doc juju"

RDEPEND=">=sys-libs/libraw1394-1.2.0[lib32?]
		juju? ( >=sys-kernel/linux-headers-2.6.23-r3 )
		X? ( x11-libs/libSM[lib32?] x11-libs/libXv[lib32?] )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

multilib-native_src_configure_internal() {
	local myconf=""
	if use juju; then
		myconf="--with-juju-dir"
	fi

	econf \
		--program-suffix=2 \
		$(use_with X x) \
		$(use_enable doc doxygen-html) \
		${myconf} \
		|| die "econf failed"
}

multilib-native_src_compile_internal() {
	emake || die "emake failed"
	if use doc ; then
		emake doc || die "emake doc failed"
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc NEWS README AUTHORS ChangeLog
	use doc && dohtml doc/html/*
}
