# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-geosciences/googleearth/googleearth-5.1.3533.1731-r1.ebuild,v 1.3 2010/04/26 19:06:59 maekke Exp $

EAPI=2

inherit eutils fdo-mime versionator toolchain-funcs

DESCRIPTION="A 3D interface to the planet"
HOMEPAGE="http://earth.google.com/"
# no upstream versioning, version determined from help/about
# incorrect digest means upstream bumped and thus needs version bump
SRC_URI="http://dl.google.com/earth/client/current/GoogleEarthLinux.bin
			-> GoogleEarthLinux-${PV}.bin"

LICENSE="googleearth MIT SGI-B-1.1 openssl as-is ZLIB"
SLOT="0"
KEYWORDS="amd64 x86"
RESTRICT="mirror strip"
IUSE="qt-bundled"

GCC_NEEDED="4.2"

RDEPEND=">=sys-devel/gcc-${GCC_NEEDED}[-nocxx]
	dev-libs/glib:2[lib32?]
	media-libs/fontconfig[lib32?]
	media-libs/freetype[lib32?]
	media-libs/mesa[lib32?]
	net-misc/curl[lib32?]
	sci-libs/gdal[lib32?]
	sys-auth/nss-mdns[lib32?]
	sys-libs/zlib[lib32?]
	virtual/opengl[lib32?]
	x11-libs/libICE[lib32?]
	x11-libs/libSM[lib32?]
	x11-libs/libX11[lib32?]
	x11-libs/libXi[lib32?]
	x11-libs/libXext[lib32?]
	x11-libs/libXrender[lib32?]
	x11-libs/libXau[lib32?]
	x11-libs/libXdmcp[lib32?]
	!qt-bundled? (
		>=x11-libs/qt-core-4.5.3[lib32?]
		>=x11-libs/qt-gui-4.5.3[lib32?]
		>=x11-libs/qt-webkit-4.5.3[lib32?]
	)
	virtual/ttf-fonts[lib32?]"

S="${WORKDIR}"

QA_TEXTRELS="opt/googleearth/libgps.so
opt/googleearth/libgooglesearch.so
opt/googleearth/libevll.so
opt/googleearth/librender.so
opt/googleearth/libinput_plugin.so
opt/googleearth/libflightsim.so
opt/googleearth/libcollada.so
opt/googleearth/libminizip.so
opt/googleearth/libauth.so
opt/googleearth/libbasicingest.so
opt/googleearth/libmeasure.so
opt/googleearth/libgoogleearth_lib.so
opt/googleearth/libmoduleframework.so
"

QA_DT_HASH="opt/${PN}/.*"

pkg_setup() {
	GCC_VER="$(gcc-version)"
	if ! version_is_at_least ${GCC_NEEDED} ${GCC_VER}; then
		ewarn "${PN} needs libraries from gcc-${GCC_NEEDED} or higher to run"
		ewarn "Your active gcc version is only ${GCC_VER}"
		ewarn "Please consult the GCC upgrade guide to set a higher version:"
		ewarn "http://www.gentoo.org/doc/en/gcc-upgrading.xml"
	fi
}

src_unpack() {
	unpack_makeself
}

src_prepare() {
	# make the postinst script only create the files; it's  installation
	# are too complicated and inserting them ourselves is easier than
	# hacking around it
	sed -i -e 's:$SETUP_INSTALLPATH/::' \
		-e 's:$SETUP_INSTALLPATH:1:' \
		-e "s:^xdg-desktop-icon.*$::" \
		-e "s:^xdg-desktop-menu.*$::" \
		-e "s:^xdg-mime.*$::" postinstall.sh
}

src_install() {
	make_wrapper ${PN} ./${PN} /opt/${PN} . || die "make_wrapper failed"
	./postinstall.sh
	insinto /usr/share/mime/packages
	doins ${PN}-mimetypes.xml || die
	domenu Google-${PN}.desktop || die
	doicon ${PN}-icon.png || die
	dodoc README.linux || die

	cd bin
	tar xf "${WORKDIR}"/${PN}-linux-x86.tar || die
	# bug #262780
	epatch "${FILESDIR}/decimal-separator.patch"
	exeinto /opt/${PN}
	doexe * || die

	cd "${D}"/opt/${PN}
	tar xf "${WORKDIR}"/${PN}-data.tar || die

	if ! use qt-bundled; then
		rm -rvf libQt{Core,Gui,Network,WebKit}.so.4 plugins/imageformats qt.conf || die
	fi
	rm -rvf libGLU.so.1 libcurl.so.4 libnss_mdns4_minimal.so.2 libgdal.so.1 || die

	fowners -R root:root /opt/${PN}
	fperms -R a-x,a+X /opt/googleearth/resources
	scanelf -qXxzm ${D}opt/${PN}/${PN}-bin
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}
