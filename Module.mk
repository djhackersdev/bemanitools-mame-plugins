cflags          += \
	-DWIN32_LEAN_AND_MEAN \
	-DWINVER=0x0601 \
	-D_WIN32_WINNT=0x0601 \
	-DCOBJMACROS \
	-Wno-attributes \

include src/main/iidxio-lua-bind/Module.mk
include src/main/util/Module.mk

#
# Distribution build rules
#

$(BUILDDIR)/mame:
	$(V)mkdir -p $@

$(BUILDDIR)/mame/iidxio_lua_bind.dll: \
		$(BUILDDIR)/mame \
		$(BUILDDIR)/bin/indep-64/iidxio-lua-bind.dll
	$(V)cp $(BUILDDIR)/bin/indep-64/iidxio-lua-bind.dll $(BUILDDIR)/mame/iidxio_lua_bind.dll

$(BUILDDIR)/mame/lua53.dll: \
		$(BUILDDIR)/mame \
		dist/lua53.dll
	$(V)cp dist/lua53.dll $(BUILDDIR)/mame/lua53.dll

$(BUILDDIR)/mame/plugins/iidxio-exit-hook/init.lua:
	$(V)mkdir -p $(shell dirname $@)
	$(V)cp src/mame/plugins/iidxio-exit-hook/init.lua $@

$(BUILDDIR)/mame/plugins/iidxio-exit-hook/plugin.json:
	$(V)mkdir -p $(shell dirname $@)
	$(V)cp src/mame/plugins/iidxio-exit-hook/plugin.json $@

$(BUILDDIR)/mame/plugins/iidxio/init.lua:
	$(V)mkdir -p $(shell dirname $@)
	$(V)cp src/mame/plugins/iidxio/init.lua $@

$(BUILDDIR)/mame/plugins/iidxio/plugin.json:
	$(V)mkdir -p $(shell dirname $@)
	$(V)cp src/mame/plugins/iidxio/plugin.json $@

$(BUILDDIR)/iidxio-mame-plugin.zip: \
		$(BUILDDIR)/mame/lua53.dll \
		$(BUILDDIR)/mame/iidxio_lua_bind.dll \
		$(BUILDDIR)/mame/plugins/iidxio/init.lua \
		$(BUILDDIR)/mame/plugins/iidxio/plugin.json \
		$(BUILDDIR)/mame/plugins/iidxio-exit-hook/init.lua \
		$(BUILDDIR)/mame/plugins/iidxio-exit-hook/plugin.json
	$(V)echo ... $@
	$(V)cd $(BUILDDIR)/mame && zip -r ../../$@ *

all: $(BUILDDIR)/iidxio-mame-plugin.zip
