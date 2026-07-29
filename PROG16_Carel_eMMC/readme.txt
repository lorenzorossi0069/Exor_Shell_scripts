Preparation of USB key for eMMC firmware replacement 

Copy all following files into root directory of a VFAT formatted USB key 

autoexec.sh
DCP00.bin
DCP00.bin.md5
DCP02.bin
DCP02.bin.md5
MLO_ORIG.img
MLO_ORIG.img.md5
MLO_RC1.img
MLO_RC1.img.md5

Then plug the USB key into target machine USB slot.
From System settings -> Services, enable "Autorun scripts from external storage"
The script autoexec.sh MUST NOT BE RENAMED



DETAILS:

The script checks if eMMC brand is SM0000, and then reads the flag state at offset 151 of I2C EEPROM

If this flag is other than predefined states, the following files are copied as follows:

In BOOT1 partition of eMMC:
DCP0o.bin
DCP02.bin

in /dev/mmcblk at offset 0x20000:
MLO_RC1.img

The I2C EEPROM flag is updated to STATE_0=0xf0 

And finally an auto-reboot is triggered with MLO_RC1


After reboot the new MLO_RC1 will update algorithm of eMMC and will set flag in one of floowing states:

STATE_1=0xe1  in case of errors
STATE_2=0xd2  if algorithm was already updated, and operation was not necessary
STATE_3=0xc3  if algorithm has been updated

Then MLO_RC1 will reboot the system and script in USB key is started again.

If flag is found in STATE_0 or STATE_1 an error message is displayed and flag is retored  to "blank" state (0xFF), else it is not changed 

In any case the original MLO_ORIG is restored for next boot


