#CMD DEFS
CP = cp
CP_R = cp -r

#Component name
COMP_NAME = asicd

#Set default build targets
BUILD_TARGET = cel_redstone

#Set paths for use during install
PARAMSDIR = $(DESTDIR)/params
DESTDIR = $(SR_CODE_BASE)/snaproute/src/out/bin
BCMDIR = $(SR_CODE_BASE)/snaproute/src/bin-AsicdBcm
MLNXDIR = $(SR_CODE_BASE)/snaproute/src/bin-AsicdMlnx
PLUGIN_MGR_DIR = $(SR_CODE_BASE)/snaproute/src/asicd/pluginManager
ASICD_DOCKER_BIN = $(SR_CODE_BASE)/snaproute/src/asicd/bin

#IPC related vars
IPC_GEN_CMD = thrift
IPC_SRCS = rpc/asicd.thrift
IPC_SVC_NAME = asicd
GENERATED_IPC = $(SR_CODE_BASE)/generated/src

#Setup defaults
BCM_TARGET = false
MLNX_TARGET = false
#Determine lib/bin paths based on build target
ifeq ($(BUILD_TARGET), cel_redstone)
	BCM_KMODS = $(BCMDIR)/cel_redstone/kmod/*.ko
	BCM_LIBS = $(BCMDIR)/cel_redstone/lib/libbcm.so.1
	BCM_TARGET = true
else ifeq ($(BUILD_TARGET), accton_as5712)
	BCM_KMODS = $(BCMDIR)/accton_as5712/kmod/*.ko
	BCM_LIBS = $(BCMDIR)/accton_as5712/lib/libbcm.so.1
	BCM_TARGET = true
else ifeq ($(BUILD_TARGET), accton_wedge40)
	BCM_KMODS = $(BCMDIR)/accton_wedge40/kmod/*.ko
	BCM_LIBS = $(BCMDIR)/accton_wedge40/lib/libbcm.so.1
	BCM_TARGET = true
endif
ifeq ($(BUILD_TARGET), mlnx_sn2700)
	SAI_LIBS = $(MLNXDIR)/mlnx_sn2700/lib/*
	MLNX_TARGET = true
endif
ifeq ($(BUILD_TARGET), cel_redstone)
	ASICD_BIN = $(BCMDIR)/cel_redstone/asicd
else ifeq ($(BUILD_TARGET), accton_as5712)
	ASICD_BIN = $(BCMDIR)/accton_as5712/asicd
else ifeq ($(BUILD_TARGET), accton_wedge40)
	ASICD_BIN = $(BCMDIR)/accton_wedge40/asicd
else ifeq ($(BUILD_TARGET), mlnx_sn2700)
	ASICD_BIN = $(MLNXDIR)/mlnx_sn2700/asicd
else
	ASICD_BIN = $(ASICD_DOCKER_BIN)/asicd
endif

#TARGETS
all:ipc

exe:
	echo "ASICd - precompiled binaries available"
	$(CP) $(ASICD_BIN) $(DESTDIR)/$(COMP_NAME)

ipc:
	$(IPC_GEN_CMD) -r --gen go -out $(GENERATED_IPC) $(IPC_SRCS)

install:
	install params/asicd.conf $(PARAMSDIR)/
ifeq ($(BCM_TARGET), true)
	$(CP_R) $(BCM_KMODS) $(DESTDIR)/kmod/
	$(CP_R) $(BCM_LIBS) $(DESTDIR)/sharedlib/
endif
ifeq ($(MLNX_TARGET), true)
	$(CP_R) $(SAI_LIBS) $(DESTDIR)/sharedlib/
endif
	$(CP_R) $(PLUGIN_MGR_DIR)/pluginCommon/utils/libhash.so.1 $(DESTDIR)/sharedlib/

clean:
	echo "No-op"
