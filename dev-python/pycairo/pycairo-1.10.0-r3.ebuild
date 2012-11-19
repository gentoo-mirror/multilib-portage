# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycairo/pycairo-1.10.0-r2.ebuild,v 1.7 2012/02/13 19:35:24 xarthisius Exp $

EAPI="4"
PYTHON_DEPEND="2:2.6 3:3.1"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.4 2.5 3.0 *-jython"

inherit eutils python waf-utils

PYCAIRO_PYTHON2_VERSION="${PV}"
PYCAIRO_PYTHON3_VERSION="${PV}"

DESCRIPTION="Python bindings for the cairo library"
HOMEPAGE="http://cairographics.org/pycairo/ http://pypi.python.org/pypi/pycairo"
SRC_URI="http://cairographics.org/releases/py2cairo-${PYCAIRO_PYTHON2_VERSION}.tar.bz2
	http://cairographics.org/releases/pycairo-${PYCAIRO_PYTHON3_VERSION}.tar.bz2
	http://dev.gentoo.org/~binki/distfiles/dev-python/${PN}/${P}-waf-multilib.patch"

# LGPL-3 for pycairo 1.10.0.
# || ( LGPL-2.1 MPL-1.1 ) for pycairo 1.8.10.
LICENSE="LGPL-3 || ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc examples +svg test xcb"

RDEPEND=">=x11-libs/cairo-1.10.0[svg?,xcb?]
	xcb? ( x11-libs/xpyb )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	test? ( dev-python/pytest )"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

# In case if waf-utils.eclass actually accepts waf-utils_waflibdir() as
# a function.
unset waf-utils_waflibdir 2>/dev/null

# @FUNCTION: waf-utils_waflibdir
# @USAGE: [<waf-binary>]
# @DESCRIPTION:
# Echoes the absolute path to the directory containing waf-based
# project's waflib python module. Ensures that the waflib shipped with a
# project is unpacked if it isn't already. This waflib may be safely
# patched because waf-lite will not touch the waflib directory when it
# is run if it already exists. Uses the waf binary in WAF_BINARY or the
# first argument.
#
# @EXAMPLE
# @CODE
# pushd "$(waf-utils_waflibdir)" || die "Unable to patch waflib"
# epatch "${FILESDIR}"/${P}-waf-fix.patch
# popd
# @CODE
#
# Note that if you are using the python eclass, you must either call
# python_set_active_version or call waf-utils_waflibdir() from within a
# function run by python_execute().
#
# @CODE
# SUPPORT_PYTHON_ABIS=1
# inherit python
#
# src_prepare() {
# 	python_copy_sources
#
# 	myprepare() {
# 		epatch "${FILESDIR}"/${P}-sourcecode-fix.patch
#
# 		pushd "$(waf-utils_saflibdir "$(PYTHON)" waf)" || die "Unable to patch waflib"
# 		epatch "${FILESDIR}"/${P}-waf-fix.patch
# 		popd
# 	}
# 	python_execute_function -s myprepare
# }
# @CODE
waf-utils_waflibdir() {
	debug-print-function ${FUNCNAME} "$@"

	# @ECLASS-VARIABLE: WAF_BINARY
	# @DESCRIPTION:
	# Eclass can use different waf executable. Usually it is located in "${S}/waf".
	: ${WAF_BINARY:="${S}/waf"}

	local waf_binary=${WAF_BINARY}
	[[ -n ${1} ]] && waf_binary=${1}

	python -c "import imp, sys; sys.argv[0] = '${waf_binary}'; waflite = imp.load_source('waflite', '${waf_binary}'); print(waflite.find_lib());" \
		|| die "Unable to locate or unpack waflib module from the waf script at ${waf_binary}"
}

# When moving between the different build dirs, we want to use the waf
# associated with each build dir.
WAF_BINARY=./waf

src_prepare() {

	pushd "${WORKDIR}/pycairo-${PYCAIRO_PYTHON3_VERSION}" > /dev/null
	rm -f src/config.h || die
	epatch "${FILESDIR}/${PN}-1.10.0-svg_check.patch"
	epatch "${FILESDIR}/${PN}-1.10.0-xpyb.patch"
	popd > /dev/null

	pushd "${WORKDIR}/py2cairo-${PYCAIRO_PYTHON2_VERSION}" > /dev/null
	rm -f src/config.h || die
	epatch "${FILESDIR}/py2cairo-1.10.0-svg_check.patch"
	epatch "${FILESDIR}/py2cairo-1.10.0-xpyb.patch"
	popd > /dev/null

	preparation() {
		local srcdir=${WORKDIR}/${P}-${PYTHON_ABI}
		if [[ "${PYTHON_ABI}" == 3.* ]]; then
			cp -r "${WORKDIR}/pycairo-${PYCAIRO_PYTHON3_VERSION}" "${srcdir}"
		else
			cp -r "${WORKDIR}/py2cairo-${PYCAIRO_PYTHON2_VERSION}" "${srcdir}"
		fi

		cd "$(waf-utils_waflibdir ${srcdir}/waf)" || die "Unable to patch waflib"
		epatch "${DISTDIR}"/${P}-waf-multilib.patch
	}
	python_execute_function preparation
}

src_configure() {
	if ! use svg; then
		export PYCAIRO_DISABLE_SVG=1
	fi

	if ! use xcb; then
		export PYCAIRO_DISABLE_XPYB=1
	fi

	python_execute_function -s waf-utils_src_configure --nopyc --nopyo
}

src_compile() {
	python_execute_function -s waf-utils_src_compile
}

src_test() {
	test_installation() {
		./waf install --destdir="${T}/tests/${PYTHON_ABI}"
	}
	python_execute_function -q -s test_installation

	python_execute_py.test -P '${T}/tests/${PYTHON_ABI}${EPREFIX}$(python_get_sitedir)' -s
}

src_install() {
	python_execute_function -s waf-utils_src_install

	dodoc AUTHORS NEWS README || die "dodoc failed"

	if use doc; then
		pushd doc/_build/html > /dev/null
		insinto /usr/share/doc/${PF}/html
		doins -r [a-z]* _static || die "Installation of documentation failed"
		popd > /dev/null
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/* || die "Installation of examples failed"
	fi
}

pkg_postinst() {
	python_mod_optimize cairo
}

pkg_postrm() {
	python_mod_cleanup cairo
}
