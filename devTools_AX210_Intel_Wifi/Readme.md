in this (new) build_kernel.sh script the make modules_install is used in cross-compile for arm64
with aid of:
INSTALL_MOD_STRIP=1 
INSTALL_MOD_PATH=<path on arm64 target-tree>

ToDo:
targetUpdate_devHost.sh is only for arm64 
For arm32 zImage must be copied)
