bin_PROGRAMS = betaradio

betaradio_SOURCES = \
                    betaradio.vala \
                    gst_player.vala \
                    json_soup.vala

betaradio_CPPFLAGS = \
                     -include config.h \
                     -DDATADIR=\"$(datadir)\" \
                     -DLOCALEDIR=\"$(localedir)\" \
                     @VALA_CFLAGS@

betaradio_LDFLAGS = @VALA_LIBS@

betaradio_VALAFLAGS = @VALA_FLAGS@ --vapidir=$(top_srcdir)/vapi --pkg config
