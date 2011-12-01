AC_PREREQ(2.65)
AC_INIT([betaradio],[1.3],[http://code.google.com/p/betaradio])
AM_MAINTAINER_MODE([enable])
AC_CONFIG_SRCDIR([src/betaradio.vala])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_HEADERS([config.h])
AM_INIT_AUTOMAKE([-Wall -Werror foreign no-dist-gzip dist-bzip2 silent-rules])
AM_SILENT_RULES([yes])

LT_PREREQ([2.2.6b])
LT_INIT

AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION(0.17)

AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_INSTALL
AM_PROG_VALAC([0.12.0])

GETTEXT_PACKAGE="$PACKAGE_NAME"
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [Gettext Package])
AC_SUBST(GETTEXT_PACKAGE)

APPINDICATOR_REQUIRED=0.0.7

AC_ARG_ENABLE(appindicator,
                        AS_HELP_STRING([--enable-appindicator[=@<:@no/auto/yes@:>@]],[Build support for application indicators ]),
                        [enable_appindicator=$enableval],
                        [enable_appindicator="auto"])

if test x$enable_appindicator = xauto ; then
        PKG_CHECK_EXISTS([appindicator-0.1 >= $APPINDICATOR_REQUIRED],
                         enable_appindicator="yes",
                         enable_appindicator="no")
fi

if test x$enable_appindicator = xyes ; then
        PKG_CHECK_EXISTS([appindicator-0.1 >= $APPINDICATOR_REQUIRED],,
                         AC_MSG_ERROR([appindicator-0.1 is not installed]))
        PKG_CHECK_MODULES(APP_INDICATOR,
                        appindicator-0.1 >= $APPINDICATOR_REQUIRED)
        AC_SUBST(APP_INDICATOR_CFLAGS)
        AC_SUBST(APP_INDICATOR_LIBS)
        AC_DEFINE(HAVE_APP_INDICATOR, 1, [Have AppIndicator])
        VALA_CFLAGS="$VALA_CFLAGS $APP_INDICATOR_CFLAGS"
        VALA_LIBS="$VALA_LIBS $APP_INDICATOR_LIBS"
        VALA_FLAGS="$VALA_FLAGS --pkg appindicator3-0.1"
fi
AM_CONDITIONAL(HAVE_APP_INDICATOR, test x"$enable_appindicator" = xyes)

PKG_CHECK_MODULES([GTK], [gtk+-2.0 >= 2.10], [
                   VALA_CFLAGS="$VALA_CFLAGS $GTK_CFLAGS"
                   VALA_LIBS="$VALA_LIBS $GTK_LIBS"
                   ], AC_MSG_ERROR([gtk+-2.0 >= 2.10 not found]))
PKG_CHECK_MODULES([GST], [gstreamer-0.10 >= 0.10], [
                   VALA_CFLAGS="$VALA_CFLAGS $GST_CFLAGS"
                   VALA_LIBS="$VALA_LIBS $GST_LIBS"
                   ], AC_MSG_ERROR([gstreamer-0.10 >= 0.10 not found]))
PKG_CHECK_MODULES([JSON], [json-glib-1.0], [
                   VALA_CFLAGS="$VALA_CFLAGS $JSON_CFLAGS"
                   VALA_LIBS="$VALA_LIBS $JSON_LIBS"
                   ], AC_MSG_ERROR([json-glib-1.0 not found]))
PKG_CHECK_MODULES([SOUP], [libsoup-2.4], [
                   VALA_CFLAGS="$VALA_CFLAGS $SOUP_CFLAGS"
                   VALA_LIBS="$VALA_LIBS $SOUP_LIBS"
                   ], AC_MSG_ERROR([libsoup-2.4 not found]))

VALA_FLAGS="$VALA_FLAGS --enable-mem-profiler --thread --pkg libsoup-2.4 --pkg json-glib-1.0 --pkg gstreamer-0.10 --pkg gtk+-2.0"

AC_SUBST(VALA_CFLAGS)
AC_SUBST(VALA_FLAGS)
AC_SUBST(VALA_LIBS)

AC_CONFIG_FILES([
                 Makefile
                 po/Makefile.in
                 data/Makefile
                 man/Makefile
                 src/Makefile
                 data/betaradio.desktop
                 vapi/Makefile
                 ])

AC_OUTPUT
