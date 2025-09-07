INSTALL_PATH ?= $$HOME
EXCLUDES     ?= ./.git ./logo.txt ./Makefile ./README.md
TAR_CMD       = find . -print0 | xargs -0 tar `echo $(EXCLUDES) | tr ' ' '\n' | awk '{print "--exclude " $$0}'` --create
UNTAR_CMD     = tar --extract --preserve-permissions --verbose --directory=$(INSTALL_PATH)

default: gazarchy

install: deps gazarchy

setup:
	@echo Installing dependencies...
	@sudo pacman -S --noconfirm ddcutil
	@yay -S --noconfirm jump
	@echo Loading i2c-dev kernel module
	@sudo modprobe i2c-dev

gazarchy:
	@(${TAR_CMD} | ${UNTAR_CMD})

.PHONY: install install-deps
