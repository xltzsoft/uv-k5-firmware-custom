
# compile options (see README.md for descriptions)
# 0 = disable
# 1 = enable

# ---- COMPILER/LINKER OPTIONS ----
ENABLE_CLANG                  ?= 0
ENABLE_SWD                    ?= 1
ENABLE_OVERLAY                ?= 0
ENABLE_LTO                    ?= 1

# ---- STOCK QUANSHENG FERATURES ----
ENABLE_UART                   ?= 1
ENABLE_AIRCOPY                ?= 1
ENABLE_FMRADIO                = 0
ENABLE_NOAA                   ?= 0
ENABLE_VOICE                  ?= 0
ENABLE_VOX                    ?= 1
ENABLE_ALARM                  ?= 0
ENABLE_TX1750                 ?= 0
ENABLE_PWRON_PASSWORD         ?= 1
ENABLE_DTMF_CALLING           ?= 1
ENABLE_FLASHLIGHT             ?= 1
ENABLE_BOOTLOADER			 ?= 0
# ---- CUSTOM MODS ----
ENABLE_BIG_FREQ               ?= 1
ENABLE_KEEP_MEM_NAME          ?= 1
ENABLE_WIDE_RX                ?= 1
ENABLE_TX_WHEN_AM             ?= 0
ENABLE_F_CAL_MENU             ?= 0
ENABLE_CTCSS_TAIL_PHASE_SHIFT ?= 0
ENABLE_BOOT_BEEPS             ?= 0
ENABLE_SHOW_CHARGE_LEVEL      ?= 1
ENABLE_REVERSE_BAT_SYMBOL     ?= 0
ENABLE_NO_CODE_SCAN_TIMEOUT   ?= 1
ENABLE_AM_FIX                 ?= 1
ENABLE_SQUELCH_MORE_SENSITIVE ?= 1
ENABLE_FASTER_CHANNEL_SCAN    ?= 1
ENABLE_RSSI_BAR               ?= 1
ENABLE_COPY_CHAN_TO_VFO       ?= 1
ENABLE_SPECTRUM               = 1
ENABLE_REDUCE_LOW_MID_TX_POWER?= 0
ENABLE_BYP_RAW_DEMODULATORS   ?= 0
ENABLE_BLMIN_TMP_OFF          ?= 0
ENABLE_SCAN_RANGES            ?= 1
ENABLE_MDC1200                = 1
ENABLE_MDC1200_SHOW_OP_ARG    = 1
ENABLE_MDC1200_SIDE_BEEP      = 1
ENABLE_MDC1200_CONTACT        = 1
ENABLE_MDC1200_EDIT			  = 1
ENABLE_UART_RW_BK_REGS 		  ?= 0
ENABLE_AUDIO_BAR_DEFAULT      ?= 0
ENABLE_EEPROM_TYPE        	   = 1
ENABLE_CHINESE_FULL 		   = 1
ENABLE_ENGLISH				    =1
ENABLE_DOCK 		          ?= 0
ENABLE_CUSTOM_SIDEFUNCTIONS   ?= 1
ENABLE_SIDEFUNCTIONS_SEND     ?= 1
ENABLE_BLOCK                  ?= 1
ENABLE_PINYIN 				   =1
ENABLE_TURN ?=1
# ---- DEBUGGING ----
ENABLE_AM_FIX_SHOW_DATA       ?= 0
ENABLE_AGC_SHOW_DATA          ?= 0
ENABLE_TIMER		          ?= 0

ENABLE_WARNING 				  ?= 1
ENABLE_MESSENGER              			= 0
ENABLE_MESSENGER_DELIVERY_NOTIFICATION	= 0
ENABLE_MESSENGER_NOTIFICATION			= 0
ENABLE_4732 =0
ENABLE_4732SSB =0

ENABLE_DOPPLER               =0
#############################################################
PACKED_FILE_SUFFIX = LOSEHU131
ifeq ($(ENABLE_PINYIN),1)
	ENABLE_CHINESE_FULL=4
endif

ifeq ($(ENABLE_DOPPLER),1)
	ENABLE_SPECTRUM=1
endif

ifeq ($(ENABLE_CHINESE_FULL),0)
    ifeq ($(ENABLE_ENGLISH),1)
        $(info E)
        PACKED_FILE_SUFFIX := $(PACKED_FILE_SUFFIX)E
    endif
endif

ifeq ($(ENABLE_CHINESE_FULL),4)

    ifeq ($(ENABLE_ENGLISH),1)
        $(info EK)
        PACKED_FILE_SUFFIX := $(PACKED_FILE_SUFFIX)EK
    else ifeq ($(ENABLE_PINYIN),1)
        $(info H)
        PACKED_FILE_SUFFIX := $(PACKED_FILE_SUFFIX)H
    else
        $(info K)
        PACKED_FILE_SUFFIX := $(PACKED_FILE_SUFFIX)K
    endif
endif
ifeq ($(ENABLE_4732),1)
	ENABLE_FMRADIO=0
	PACKED_FILE_SUFFIX := $(PACKED_FILE_SUFFIX)S
    $(info SI4732)

endif
ifeq ($(ENABLE_FMRADIO),1)
	ENABLE_4732=0
endif


CFLAGS =


ifeq ($(ENABLE_MDC1200),0)
	ENABLE_MDC1200_SHOW_OP_ARG    = 0
	ENABLE_MDC1200_SIDE_BEEP      = 0
	ENABLE_MDC1200_CONTACT        = 0
	ENABLE_MDC1200_EDIT			=0
endif




OPENOCD = openocd-win/bin/openocd.exe
TARGET = firmware

ifeq ($(ENABLE_CLANG),1)
	# GCC's linker, ld, doesn't understand LLVM's generated bytecode
	ENABLE_LTO := 0
endif

ifeq ($(ENABLE_LTO),1)
	# can't have LTO and OVERLAY enabled at same time
	ENABLE_OVERLAY := 0
endif

BSP_DEFINITIONS := $(wildcard hardware/*/*.def)
BSP_HEADERS     := $(patsubst hardware/%,bsp/%,$(BSP_DEFINITIONS))
BSP_HEADERS     := $(patsubst %.def,%.h,$(BSP_HEADERS))

OBJS =
# Startup files
OBJS += start.o
OBJS += init.o
OBJS += app/messenger.o

ifeq ($(ENABLE_MESSENGER),1)
	OBJS += ui/messenger.o
endif




ifeq ($(ENABLE_OVERLAY),1)
	OBJS += sram-overlay.o
endif
OBJS += external/printf/printf.o
ifeq ($(ENABLE_TIMER),1)
    OBJS += driver/rtc.o
endif
ifeq ($(ENABLE_DOPPLER),1)
    OBJS += driver/rtc.o
endif

ifeq ($(ENABLE_MDC1200),1)
    OBJS += app/mdc1200.o
endif
ifeq ($(ENABLE_DOPPLER),1)
    OBJS += app/doppler.o
endif
# Drivers
OBJS += driver/adc.o
ifeq ($(ENABLE_UART),1)
	OBJS += driver/aes.o
endif
OBJS += driver/backlight.o
ifeq ($(ENABLE_FMRADIO),1)
	OBJS += driver/bk1080.o
endif
OBJS += driver/bk4819.o
ifeq ($(filter $(ENABLE_AIRCOPY) $(ENABLE_UART),1),1)
	OBJS += driver/crc.o
endif
OBJS += driver/eeprom.o
ifeq ($(ENABLE_OVERLAY),1)
	OBJS += driver/flash.o
endif
ifeq ($(ENABLE_4732),1)
        OBJS += app/si.o
        OBJS += driver/si473x.o
        OBJS += helper/rds.o
        OBJS += app/spectrum.o
endif
OBJS += driver/gpio.o
OBJS += driver/i2c.o
OBJS += driver/keyboard.o
OBJS += driver/spi.o
OBJS += driver/st7565.o
OBJS += driver/system.o
OBJS += driver/systick.o
ifeq ($(ENABLE_UART),1)
	OBJS += driver/uart.o
endif

# Main
OBJS += app/action.o
ifeq ($(ENABLE_AIRCOPY),1)
	OBJS += app/aircopy.o
endif
OBJS += app/app.o
OBJS += app/chFrScanner.o
OBJS += app/common.o
OBJS += app/dtmf.o
ifeq ($(ENABLE_FLASHLIGHT),1)
	OBJS += app/flashlight.o
endif
ifeq ($(ENABLE_FMRADIO),1)
	OBJS += app/fm.o
endif
OBJS += app/generic.o
OBJS += app/main.o
OBJS += app/menu.o
ifeq ($(ENABLE_SPECTRUM), 1)
OBJS += app/spectrum.o
endif
OBJS += app/scanner.o
ifeq ($(ENABLE_UART),1)
	OBJS += app/uart.o
endif
ifeq ($(ENABLE_AM_FIX), 1)
	OBJS += am_fix.o
endif
OBJS += audio.o
OBJS += bitmaps.o
OBJS += board.o
OBJS += dcs.o
OBJS += font.o
OBJS += frequencies.o
OBJS += functions.o
OBJS += helper/battery.o
OBJS += helper/boot.o
OBJS += misc.o
OBJS += radio.o
OBJS += scheduler.o
OBJS += settings.o
ifeq ($(ENABLE_AIRCOPY),1)
	OBJS += ui/aircopy.o
endif
OBJS += ui/battery.o
ifeq ($(ENABLE_FMRADIO),1)
	OBJS += ui/fmradio.o
endif
OBJS += ui/helper.o
OBJS += ui/inputbox.o
ifeq ($(ENABLE_PWRON_PASSWORD),1)
	OBJS += ui/lock.o
endif
OBJS += ui/main.o
OBJS += ui/menu.o
OBJS += ui/scanner.o
OBJS += ui/status.o
OBJS += ui/ui.o
OBJS += ui/welcome.o
OBJS += version.o
OBJS += main.o

ifeq ($(OS), Windows_NT) # windows
    TOP := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
    RM = del /Q
    FixPath = $(subst /,\,$1)
    WHERE = where
    NULL_OUTPUT = nul
else # unix
    TOP := $(shell pwd)
    RM = rm -f
    FixPath = $1
    WHERE = which
    NULL_OUTPUT = /dev/null
endif


AS = arm-none-eabi-gcc
LD = arm-none-eabi-gcc

ifeq ($(ENABLE_CLANG),0)
	CC = arm-none-eabi-gcc
# Use GCC's linker to avoid undefined symbol errors
#	LD += arm-none-eabi-gcc
else
#	May need to adjust this to match your system
	CC = clang --sysroot=/usr/arm-none-eabi --target=arm-none-eabi
#	Bloats binaries to 512MB
#	LD = ld.lld
endif

OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

AUTHOR_STRING ?= LOSEHU
# the user might not have/want git installed
# can set own version string here (max 7 chars)
ifneq (, $(shell $(WHERE) git))
	VERSION_STRING ?= $(shell git describe --tags --exact-match 2>$(NULL_OUTPUT))
	ifeq (, $(VERSION_STRING))
    	VERSION_STRING := $(shell git rev-parse --short HEAD)
	endif
endif
# If there is still no VERSION_STRING we need to make one.
# It is needed for the firmware packing script
ifeq (, $(VERSION_STRING))
	VERSION_STRING := NOGIT
endif
#VERSION_STRING := 230930b


ASFLAGS = -c -mcpu=cortex-m0
ifeq ($(ENABLE_OVERLAY),1)
	ASFLAGS += -DENABLE_OVERLAY
endif

ifeq ($(ENABLE_CLANG),0)
	CFLAGS += -Os -Wall -Wno-error -mcpu=cortex-m0 -fno-builtin -fshort-enums -fno-delete-null-pointer-checks -std=c2x -MMD -w
	#CFLAGS += -Os -Wall -Werror -mcpu=cortex-m0 -fno-builtin -fshort-enums -fno-delete-null-pointer-checks -std=c11 -MMD
	#CFLAGS += -Os -Wall -Werror -mcpu=cortex-m0 -fno-builtin -fshort-enums -fno-delete-null-pointer-checks -std=c99 -MMD
	#CFLAGS += -Os -Wall -Werror -mcpu=cortex-m0 -fno-builtin -fshort-enums -fno-delete-null-pointer-checks -std=gnu99 -MMD
	#CFLAGS += -Os -Wall -Werror -mcpu=cortex-m0 -fno-builtin -fshort-enums -fno-delete-null-pointer-checks -std=gnu11 -MMD
else
	# Oz needed to make it fit on flash
	CFLAGS += -Oz -Wall -Werror -mcpu=cortex-m0 -fno-builtin -fshort-enums -fno-delete-null-pointer-checks -std=c2x -MMD
endif

ifeq ($(ENABLE_LTO),1)
	CFLAGS += -flto=auto
else
	# We get most of the space savings if LTO creates problems
	CFLAGS += -ffunction-sections -fdata-sections
endif

# May cause unhelpful build failures
#CFLAGS += -Wpadded

# catch any and all warnings
CFLAGS += -Wextra
#CFLAGS += -Wpedantic

# 设置PACKED_FILE_SUFFIX，根据ENABLE_CHINESE_FULL的值设置不同的后缀

CFLAGS += -DENABLE_EEPROM_TYPE=$(ENABLE_EEPROM_TYPE)

CFLAGS += -DENABLE_CHINESE_FULL=$(ENABLE_CHINESE_FULL)
CFLAGS += -DPACKED_FILE_SUFFIX=\"$(PACKED_FILE_SUFFIX)\"
CFLAGS += -DPRINTF_INCLUDE_CONFIG_H
CFLAGS += -DAUTHOR_STRING=\"$(AUTHOR_STRING)\" -DVERSION_STRING=\"$(VERSION_STRING)\"

ifeq ($(ENABLE_MDC1200_EDIT),1)
CFLAGS += -DENABLE_MDC1200_EDIT
endif
ifeq ($(ENABLE_SPECTRUM),1)
CFLAGS += -DENABLE_SPECTRUM
endif
ifeq ($(ENABLE_MDC1200),1)
    CFLAGS  += -DENABLE_MDC1200
endif
ifeq ($(ENABLE_BOOTLOADER),1)
    CFLAGS  += -DENABLE_BOOTLOADER
endif

ifeq ($(ENABLE_WARNING),1)
    CFLAGS  += -DENABLE_WARNING
endif

ifeq ($(ENABLE_DOCK),1)
    CFLAGS  += -DENABLE_DOCK
endif
ifeq ($(ENABLE_ENGLISH),1)
    CFLAGS  += -DENABLE_ENGLISH
endif

ifeq ($(ENABLE_PINYIN),1)
	CFLAGS += -DENABLE_PINYIN
endif
ifeq ($(ENABLE_TURN),1)
	CFLAGS += -DENABLE_TURN
endif

ifeq ($(ENABLE_BLOCK),1)
	CFLAGS += -DENABLE_BLOCK
endif
ifeq ($(ENABLE_MESSENGER),1)
	CFLAGS  += -DENABLE_MESSENGER
endif
ifeq ($(ENABLE_DOPPLER),1)
	CFLAGS  += -DENABLE_DOPPLER
endif
ifeq ($(ENABLE_4732),1)
	CFLAGS  += -DENABLE_4732
endif
ifeq ($(ENABLE_4732SSB),1)
	CFLAGS  += -DENABLE_4732SSB
endif
ifeq ($(ENABLE_MESSENGER_DELIVERY_NOTIFICATION),1)
	CFLAGS += -DENABLE_MESSENGER_DELIVERY_NOTIFICATION
endif
ifeq ($(ENABLE_MESSENGER_NOTIFICATION),1)
	CFLAGS += -DENABLE_MESSENGER_NOTIFICATION
endif
#ifeq ($(ENABLE_CHINESE_FULL),4)
ifeq ($(ENABLE_CUSTOM_SIDEFUNCTIONS),1)
    CFLAGS  += -DENABLE_CUSTOM_SIDEFUNCTIONS
endif
ifeq ($(ENABLE_SIDEFUNCTIONS_SEND),1)
    CFLAGS  += -DENABLE_SIDEFUNCTIONS_SEND
endif
#endif

ifeq ($(ENABLE_TIMER),1)
    CFLAGS  += -DENABLE_TIMER
endif


ifeq ($(ENABLE_MDC1200_CONTACT),1)
    CFLAGS  += -DENABLE_MDC1200_CONTACT
endif
ifeq ($(ENABLE_AUDIO_BAR_DEFAULT),1)
    CFLAGS  += -DENABLE_AUDIO_BAR_DEFAULT
endif
ifeq ($(ENABLE_CHINESE_FULL),4)

ifeq ($(ENABLE_EEPROM_4M),1)
    CFLAGS  += -DENABLE_EEPROM_4M
endif
endif

ifeq ($(ENABLE_MDC1200_SHOW_OP_ARG),1)
    CFLAGS  += -DENABLE_MDC1200_SHOW_OP_ARG
endif
ifeq ($(ENABLE_MDC1200_SIDE_BEEP),1)
    CFLAGS  += -DENABLE_MDC1200_SIDE_BEEP
endif

ifeq ($(ENABLE_SWD),1)
	CFLAGS += -DENABLE_SWD
endif
ifeq ($(ENABLE_OVERLAY),1)
	CFLAGS += -DENABLE_OVERLAY
endif
ifeq ($(ENABLE_AIRCOPY),1)
	CFLAGS += -DENABLE_AIRCOPY
endif
ifeq ($(ENABLE_FMRADIO),1)
	CFLAGS += -DENABLE_FMRADIO
endif
ifeq ($(ENABLE_UART),1)
	CFLAGS += -DENABLE_UART
endif
ifeq ($(ENABLE_UART_RW_BK_REGS),1)
	CFLAGS  += -DENABLE_UART_RW_BK_REGS
endif
ifeq ($(ENABLE_BIG_FREQ),1)
	CFLAGS  += -DENABLE_BIG_FREQ
endif

ifeq ($(ENABLE_NOAA),1)
	CFLAGS  += -DENABLE_NOAA
endif
ifeq ($(ENABLE_VOICE),1)
	CFLAGS  += -DENABLE_VOICE
endif
ifeq ($(ENABLE_VOX),1)
	CFLAGS  += -DENABLE_VOX
endif
ifeq ($(ENABLE_ALARM),1)
	CFLAGS  += -DENABLE_ALARM
endif
ifeq ($(ENABLE_TX1750),1)
	CFLAGS  += -DENABLE_TX1750
endif
ifeq ($(ENABLE_PWRON_PASSWORD),1)
	CFLAGS  += -DENABLE_PWRON_PASSWORD
endif
ifeq ($(ENABLE_KEEP_MEM_NAME),1)
	CFLAGS  += -DENABLE_KEEP_MEM_NAME
endif
ifeq ($(ENABLE_WIDE_RX),1)
	CFLAGS  += -DENABLE_WIDE_RX
endif
ifeq ($(ENABLE_TX_WHEN_AM),1)
	CFLAGS  += -DENABLE_TX_WHEN_AM
endif
ifeq ($(ENABLE_F_CAL_MENU),1)
	CFLAGS  += -DENABLE_F_CAL_MENU
endif
ifeq ($(ENABLE_CTCSS_TAIL_PHASE_SHIFT),1)
	CFLAGS  += -DENABLE_CTCSS_TAIL_PHASE_SHIFT
endif
ifeq ($(ENABLE_BOOT_BEEPS),1)
	CFLAGS  += -DENABLE_BOOT_BEEPS
endif
ifeq ($(ENABLE_SHOW_CHARGE_LEVEL),1)
	CFLAGS  += -DENABLE_SHOW_CHARGE_LEVEL
endif
ifeq ($(ENABLE_REVERSE_BAT_SYMBOL),1)
	CFLAGS  += -DENABLE_REVERSE_BAT_SYMBOL
endif
ifeq ($(ENABLE_NO_CODE_SCAN_TIMEOUT),1)
	CFLAGS += -DENABLE_NO_CODE_SCAN_TIMEOUT
endif
ifeq ($(ENABLE_AM_FIX),1)
	CFLAGS  += -DENABLE_AM_FIX
endif
ifeq ($(ENABLE_AM_FIX_SHOW_DATA),1)
	CFLAGS  += -DENABLE_AM_FIX_SHOW_DATA
endif
ifeq ($(ENABLE_SQUELCH_MORE_SENSITIVE),1)
	CFLAGS  += -DENABLE_SQUELCH_MORE_SENSITIVE
endif
ifeq ($(ENABLE_FASTER_CHANNEL_SCAN),1)
	CFLAGS  += -DENABLE_FASTER_CHANNEL_SCAN
endif
ifeq ($(ENABLE_BACKLIGHT_ON_RX),1)
	CFLAGS  += -DENABLE_BACKLIGHT_ON_RX
endif
ifeq ($(ENABLE_RSSI_BAR),1)
	CFLAGS  += -DENABLE_RSSI_BAR
endif
ifeq ($(ENABLE_AUDIO_BAR),1)
	CFLAGS  += -DENABLE_AUDIO_BAR
endif
ifeq ($(ENABLE_COPY_CHAN_TO_VFO),1)
	CFLAGS  += -DENABLE_COPY_CHAN_TO_VFO
endif
ifeq ($(ENABLE_SINGLE_VFO_CHAN),1)
	CFLAGS  += -DENABLE_SINGLE_VFO_CHAN
endif
ifeq ($(ENABLE_BAND_SCOPE),1)
	CFLAGS += -DENABLE_BAND_SCOPE
endif
ifeq ($(ENABLE_REDUCE_LOW_MID_TX_POWER),1)
	CFLAGS  += -DENABLE_REDUCE_LOW_MID_TX_POWER
endif
ifeq ($(ENABLE_BYP_RAW_DEMODULATORS),1)
	CFLAGS  += -DENABLE_BYP_RAW_DEMODULATORS
endif

ifeq ($(ENABLE_SCAN_RANGES),1)
	CFLAGS  += -DENABLE_SCAN_RANGES
endif
ifeq ($(ENABLE_DTMF_CALLING),1)
	CFLAGS  += -DENABLE_DTMF_CALLING
endif
ifeq ($(ENABLE_AGC_SHOW_DATA),1)
	CFLAGS  += -DENABLE_AGC_SHOW_DATA
endif
ifeq ($(ENABLE_FLASHLIGHT),1)
	CFLAGS  += -DENABLE_FLASHLIGHT
endif

LDFLAGS =
LDFLAGS += -z noexecstack -mcpu=cortex-m0 -nostartfiles -Wl,-T,firmware.ld -Wl,--gc-sections

# Use newlib-nano instead of newlib
LDFLAGS += --specs=nano.specs

ifeq ($(DEBUG),1)
	ASFLAGS += -g
	CFLAGS  += -g
	LDFLAGS += -g
endif

INC =
INC += -I $(TOP)
INC += -I $(TOP)/external/CMSIS_5/CMSIS/Core/Include/
INC += -I $(TOP)/external/CMSIS_5/Device/ARM/ARMCM0/Include

LIBS =


DEPS = $(OBJS:.o=.d)



ifneq (, $(shell $(WHERE) python))
    MY_PYTHON := python
else ifneq (, $(shell $(WHERE) python3))
    MY_PYTHON := python3
endif

ifdef MY_PYTHON
    HAS_CRCMOD := $(shell $(MY_PYTHON) -c "import crcmod" 2>&1)
endif

full:
	$(RM) *.bin
	$(MAKE) build ENABLE_CHINESE_FULL=0 ENABLE_ENGLISH=1 ENABLE_FMRADIO=1 ENABLE_MESSENGER=1 ENABLE_MESSENGER_DELIVERY_NOTIFICATION=1 ENABLE_MESSENGER_NOTIFICATION=1 ENABLE_SPECTRUM=1 ENABLE_MDC1200=1 ENABLE_MDC1200_EDIT=1 ENABLE_MDC1200_CONTACT=1
	$(MAKE) build ENABLE_CHINESE_FULL=4 ENABLE_ENGLISH=1 ENABLE_DOPPLER=1 ENABLE_SPECTRUM=1 ENABLE_FMRADIO=1 ENABLE_MDC1200=1 ENABLE_MDC1200_EDIT=1 ENABLE_MDC1200_CONTACT=1
	$(MAKE) build ENABLE_CHINESE_FULL=0 ENABLE_SPECTRUM=1 ENABLE_FMRADIO=1 ENABLE_MDC1200=1 ENABLE_MDC1200_EDIT=1 ENABLE_MDC1200_CONTACT=1
	$(MAKE) build ENABLE_CHINESE_FULL=4 ENABLE_DOPPLER=1 ENABLE_SPECTRUM=1 ENABLE_FMRADIO=1 ENABLE_MDC1200=1 ENABLE_MDC1200_EDIT=1 ENABLE_MDC1200_CONTACT=1
	$(MAKE) build ENABLE_CHINESE_FULL=4 ENABLE_DOPPLER=1 ENABLE_PINYIN=1 ENABLE_SPECTRUM=1 ENABLE_FMRADIO=1
	$(MAKE) build ENABLE_CHINESE_FULL=4 ENABLE_PINYIN=1 ENABLE_4732=1 ENABLE_4732SSB=1  ENABLE_SPECTRUM=1

test:
	$(RM) *.bin
	$(MAKE) build ENABLE_CHINESE_FULL=0   ENABLE_MDC1200=0 ENABLE_MDC1200_EDIT=0 ENABLE_MDC1200_CONTACT=0 ENABLE_FMRADIO=0 ENABLE_MESSENGER=1 ENABLE_MESSENGER_DELIVERY_NOTIFICATION=1 ENABLE_MESSENGER_NOTIFICATION=1



build:clean $(TARGET)
	@$(OBJCOPY) -O binary $(TARGET) $(TARGET).bin
ifndef MY_PYTHON
	$(info )
	$(info )
else ifneq (,$(HAS_CRCMOD))
	$(info )
	$(info !!!!!!!! run: pip install crcmod)
	$(info )
else
	-$(MY_PYTHON) fw-pack.py $(TARGET).bin $(AUTHOR_STRING) $(PACKED_FILE_SUFFIX).bin
endif
	$(SIZE) $(TARGET)





all:
	$(MAKE) build
	$(MAKE) flash

debug:
	$(OPENOCD) -c "bindto 0.0.0.0" -f interface/stlink.cfg -f dp32g030.cfg

flash:
	$(OPENOCD) -c "bindto 0.0.0.0" -f interface/stlink.cfg -f dp32g030.cfg -c "write_image firmware.bin 0; shutdown;"

version.o: .FORCE

$(TARGET): $(OBJS)
	@$(LD) $(LDFLAGS) $^ -o $@ $(LIBS)

bsp/dp32g030/%.h: hardware/dp32g030/%.def

%.o: %.c | $(BSP_HEADERS)
	@$(CC) $(CFLAGS) $(INC) -c $< -o $@

%.o: %.S
	@$(AS) $(ASFLAGS) $< -o $@

.FORCE:

-include $(DEPS)

CUSCANSHU ?= NUL
CUSTOMNAME ?= NUL
full_all:
	$(MAKE) build_all $(CUSCANSHU) CUSTOMNAME="$(CUSTOMNAME)"


build_all: clean $(TARGET)
	$(OBJCOPY) -O binary $(TARGET) $(TARGET).bin
ifndef MY_PYTHON

else ifneq (,$(HAS_CRCMOD))
	$(info )
	$(info !!!!!!!! run: pip install crcmod)
	$(info )
else
	-$(MY_PYTHON) fw-pack.py $(TARGET).bin $(AUTHOR_STRING) $(CUSTOMNAME).bin
endif
	$(SIZE) $(TARGET)




clean:
	@$(RM) $(call FixPath, $(TARGET).bin $(PACKED_FILE_SUFFIX).bin $(TARGET) )

ifeq ($(OS), Windows_NT) # Windows 系统
	@call del_win.bat
else # 类 Unix 系统（Linux, macOS, 等）
	chmod +x del_linux.sh
	sh ./del_linux.sh
endif

