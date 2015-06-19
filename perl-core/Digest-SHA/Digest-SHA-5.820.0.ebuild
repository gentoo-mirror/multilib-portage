# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Digest-SHA/Digest-SHA-5.820.0.ebuild,v 1.10 2013/02/23 08:33:13 ago Exp $

EAPI=5

MODULE_AUTHOR=MSHELOR
MODULE_VERSION=5.82
inherit perl-module

DESCRIPTION="Perl extension for SHA-1/224/256/384/512"

SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh sparc x86 ~ppc-aix ~amd64-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

SRC_TEST="do"

pkg_setup() {
	# bug #458930, necessary until bug #261375 is fixed.
	myconf=(
		OPTIMIZE="${CFLAGS}"
	)
	perl-module_pkg_setup
}
