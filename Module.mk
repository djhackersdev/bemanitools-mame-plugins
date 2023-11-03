cflags          += \
	-DWIN32_LEAN_AND_MEAN \
	-DWINVER=0x0601 \
	-D_WIN32_WINNT=0x0601 \
	-DCOBJMACROS \
	-Wno-attributes \

include src/main/ddrio-lua-bind/Module.mk
include src/main/iidxio-lua-bind/Module.mk
include src/main/util/Module.mk

#
# Distribution build rules
#

#
# Beatmania IIDX
#

$(BUILDDIR)/mame-iidx:
	$(V)mkdir -p $@

$(BUILDDIR)/mame-iidx/iidxio_lua_bind.dll: \
		$(BUILDDIR)/mame-iidx \
		$(BUILDDIR)/bin/indep-64/iidxio-lua-bind.dll
	$(V)cp $(BUILDDIR)/bin/indep-64/iidxio-lua-bind.dll $(BUILDDIR)/mame-iidx/iidxio_lua_bind.dll

$(BUILDDIR)/mame-iidx/lua54.dll: \
		$(BUILDDIR)/mame-iidx \
		dist/lua54.dll
	$(V)cp dist/lua54.dll $(BUILDDIR)/mame-iidx/lua54.dll

$(BUILDDIR)/mame-iidx/plugins/iidxio/init.lua:
	$(V)mkdir -p $(shell dirname $@)
	$(V)cp src/mame/plugins/iidxio/init.lua $@

$(BUILDDIR)/mame-iidx/plugins/iidxio/plugin.json:
	$(V)mkdir -p $(shell dirname $@)
	$(V)cp src/mame/plugins/iidxio/plugin.json $@

$(BUILDDIR)/iidxio-mame-plugin.zip: \
		$(BUILDDIR)/mame-iidx/lua54.dll \
		$(BUILDDIR)/mame-iidx/iidxio_lua_bind.dll \
		$(BUILDDIR)/mame-iidx/plugins/iidxio/init.lua \
		$(BUILDDIR)/mame-iidx/plugins/iidxio/plugin.json
	$(V)echo ... $@
	$(V)cd $(BUILDDIR)/mame-iidx && zip -r ../../$@ *

#
# Dance Dance Revolution
#

$(BUILDDIR)/mame-ddr:
	$(V)mkdir -p $@

$(BUILDDIR)/mame-ddr/ddrio_lua_bind.dll: \
		$(BUILDDIR)/mame-ddr \
		$(BUILDDIR)/bin/indep-64/ddrio-lua-bind.dll
	$(V)cp $(BUILDDIR)/bin/indep-64/ddrio-lua-bind.dll $(BUILDDIR)/mame-ddr/ddrio_lua_bind.dll

$(BUILDDIR)/mame-ddr/lua54.dll: \
		$(BUILDDIR)/mame-ddr \
		dist/lua54.dll
	$(V)cp dist/lua54.dll $(BUILDDIR)/mame-ddr/lua54.dll

$(BUILDDIR)/mame-ddr/plugins/ddrio/init.lua:
	$(V)mkdir -p $(shell dirname $@)
	$(V)cp src/mame/plugins/ddrio/init.lua $@

$(BUILDDIR)/mame-ddr/plugins/ddrio/plugin.json:
	$(V)mkdir -p $(shell dirname $@)
	$(V)cp src/mame/plugins/ddrio/plugin.json $@

$(BUILDDIR)/ddrio-mame-plugin.zip: \
		$(BUILDDIR)/mame-ddr/lua54.dll \
		$(BUILDDIR)/mame-ddr/ddrio_lua_bind.dll \
		$(BUILDDIR)/mame-ddr/plugins/ddrio/init.lua \
		$(BUILDDIR)/mame-ddr/plugins/ddrio/plugin.json
	$(V)echo ... $@
	$(V)cd $(BUILDDIR)/mame-ddr && zip -r ../../$@ *

#
# Final packages
#

$(BUILDDIR)/bemanitools-mame-plugins.zip: \
		$(BUILDDIR)/iidxio-mame-plugin.zip \
		$(BUILDDIR)/ddrio-mame-plugin.zip \
		CHANGELOG.md \
		LICENSE \
		README.md \
		version
	$(V)echo ... $@
	$(V)zip -j $@ $^

all: $(BUILDDIR)/bemanitools-mame-plugins.zip