# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Wraps binarys that behave abi dependand"
HOMEPAGE="www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE=""

# nothing to strip
RESTRICT="strip"

src_unpack() {
	local abis="${DEFAULT_ABI} ${MULTILIB_ABIS/${DEFAULT_ABI}}"
	sed "s/@HARDCODED_ABIS@/${abis}/" "${FILESDIR}"/abi-wrapper > "${WORKDIR}"/abi-wrapper
}

src_install() {
	into /
	dobin abi-wrapper || die
	insinto /usr/bin
	ln -s ../../bin/abi-wrapper "${D}"usr/bin/abi-wrapper || die
	newbin /bin/bash bash-abi-wrapper || die
	newbin /bin/readlink readlink-abi-wrapper || die
}
