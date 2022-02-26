.PHONY: build-vm

build-vm:
	nixos-rebuild build-vm-with-bootloader --flake .#test-vm
