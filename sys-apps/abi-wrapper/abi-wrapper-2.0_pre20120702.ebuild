# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit autotools-utils multilib

DESCRIPTION="Wraps binaries which have implementations for different ABIs"
HOMEPAGE="http://gentoo.org/~binki/abi-wrapper.xhtml https://bitbucket.org/gentoo/abi-wrapper"
SRC_URI="ftp://mirror.ohnopub.net/mirror/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="doc"

DEPEND="doc? ( app-text/txt2man )"

src_configure() {
	local myeconfargs=(
		# Because portage resolves python's sys.executable value by
		# reading the symlink repeatedly, portage will end up trying to
		# directly execute "abi-wrapper" if abi-wrapper preserves
		# argv[0]. Thus blacklist python from argv[0] preservation.
		# http://git.overlays.gentoo.org/gitweb/?p=proj/portage.git;a=blob;f=pym/portage/__init__.py;h=46bdc961c04a01f9bd92af8b0751e43dfea2029d;hb=d44df83d9f00405a62b25439ddc1915e6366a300#l334
		# Portage does this because it is afraid that it may leave the
		# python symlink in an inconstent state or replace it with an
		# incompatible version of python, so portage needs to learn that
		# abi-wrapper exists eventually...
		MULTILIB_BINARIES_NO_CANONICAL='python*'

		# Ensure that the default ABI is prioritized.
		MULTILIB_ABIS="${DEFAULT_ABI} ${MULTILIB_ABIS/${DEFAULT_ABI}}"

		# Support separate /usr.
		--bindir="${EPREFIX}"/bin
		--libexecdir="${EPREFIX}"/"$(get_libdir)"
	)
	use doc || myeconfargs+=(TXT2MAN=false)

	autotools-utils_src_configure
}

src_install() {
	autotools-utils_src_install

	dosym ../../bin/abi-wrapper /usr/bin/abi-wrapper
}
