# This is a FSL Android Reference Design platform based on i.MX6Q ARD board
# It will inherit from FSL core product which in turn inherit from Google generic

$(call inherit-product, device/fsl/imx6/imx6.mk)
$(call inherit-product-if-exists,vendor/google/products/gms.mk)

ifneq ($(wildcard device/fsl/evk_6dq/fstab_nand.freescale),)
$(shell touch device/fsl/evk_6sl/fstab_nand.freescale)
endif

ifneq ($(wildcard device/fsl/evk_6dq/fstab.freescale),)
$(shell touch device/fsl/evk_6sl/fstab.freescale)
endif

# Overrides
PRODUCT_NAME := evk_6sl
PRODUCT_DEVICE := evk_6sl

# eink apk
PRODUCT_PACKAGES += \
         Highlight     \
         HandWriting   \
         HandWriting2  \
         FastPageTurn  \
         Concurrent    \
         Animation

PRODUCT_COPY_FILES += \
	device/fsl/evk_6sl/required_hardware.xml:system/etc/permissions/required_hardware.xml \
	device/fsl/evk_6sl/init.rc:root/init.freescale.rc \
	device/fsl/common/input/ft5x0x_ts.idc:system/usr/idc/ft5x0x_ts.idc \
	device/fsl/common/input/imx-keypad.idc:system/usr/idc/imx-keypad.idc \
	device/fsl/common/input/imx-keypad.kl:system/usr/keylayout/imx-keypad.kl \
	device/fsl/evk_6sl/audio_policy.conf:system/etc/audio_policy.conf \
	device/fsl/evk_6sl/audio_effects.conf:system/vendor/etc/audio_effects.conf \
	device/fsl/evk_6sl/bcmdhd.ko:system/lib/modules

# broadcom wifi
PRODUCT_COPY_FILES += \
	device/fsl/evk_6sl/bcmdhd.ko:system/lib/modules/bcmdhd.ko \
	device/fsl/common/wifi/bcmdhd.cal:system/etc/wifi/bcmdhd.cal \
	device/fsl/common/wifi/fw_43340_nw_bcmdhd.bin:vendor/firmware/fw_bcmdhd.bin

DEVICE_PACKAGE_OVERLAYS := device/fsl/evk_6sl/overlay
PRODUCT_CHARACTERISTICS := tablet
PRODUCT_AAPT_CONFIG += xlarge large tvdpi hdpi
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
	frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
	frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:system/etc/permissions/android.hardware.sensor.gyroscope.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
	frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
	frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml

# for PDK build, include only when the dir exists
# too early to use $(TARGET_BUILD_PDK)
ifneq ($(wildcard packages/wallpapers/LivePicker),)
PRODUCT_COPY_FILES += \
	packages/wallpapers/LivePicker/android.software.live_wallpaper.xml:system/etc/permissions/android.software.live_wallpaper.xml
endif

# broadcom wifi
$(call inherit-product-if-exists, hardware/broadcom/wlan/bcmdhd/firmware/bcm43341/device-bcm.mk)
