# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/lcms/lcms-1.18.ebuild,v 1.5 2009/04/04 16:11:10 ranger Exp $

EAPI="2"

MULTILIB_IN_SOURCE_BUILD="yes"

inherit libtool eutils multilib multilib-native

DESCRIPTION="A lightweight, speed optimized color management engine"
HOMEPAGE="http://www.littlecms.com/"
SRC_URI="http://www.littlecms.com/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ppc ppc64 ~s390 ~sh ~sparc x86 ~x86-fbsd"
IUSE="tiff jpeg zlib python"

RDEPEND="tiff? ( media-libs/tiff )
	jpeg? ( media-libs/jpeg )
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}
	python? ( >=dev-lang/swig-1.3.31 )"

src_prepare() {
	# run swig to regenerate lcms_wrap.cxx and lcms.py (bug #148728)
	if use python; then
		cd "${S}"/python
		./swig_lcms || die "swig_lcms failed"
	fi
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		$(use_with jpeg) \
		$(use_with python) \
		$(use_with tiff) \
		$(use_with zlib)
}

multilib-native_src_install_internal() {
	emake \
		DESTDIR="${D}" \
		BINDIR="${D}"/usr/bin \
		libdir=/usr/$(get_libdir) \
		install || die "make install failed"

	insinto /usr/share/lcms/profiles
	doins testbed/*.icm

	dodoc AUTHORS README* INSTALL NEWS doc/*
}
