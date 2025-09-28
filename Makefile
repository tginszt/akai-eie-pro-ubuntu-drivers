# Makefile for AKAI EIE Pro USB Audio Driver

# Module name
MODULE_NAME = akai_eie_pro

# Object files
obj-m := $(MODULE_NAME).o

# Kernel source directory (adjust if needed)
KERNEL_SRC ?= /lib/modules/$(shell uname -r)/build

# Current directory
PWD := $(shell pwd)

# Default target
all: modules

# Build the kernel module
modules:
	@echo "Building AKAI EIE Pro driver..."
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) modules

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	$(MAKE) -C $(KERNEL_SRC) M=$(PWD) clean
	rm -f Module.symvers modules.order

# Install the module (requires root)
install: modules
	@echo "Installing module..."
	sudo cp $(MODULE_NAME).ko /lib/modules/$(shell uname -r)/extra/
	sudo depmod -a
	@echo "Module installed. Load with: sudo modprobe $(MODULE_NAME)"

# Uninstall the module
uninstall:
	@echo "Uninstalling module..."
	sudo rm -f /lib/modules/$(shell uname -r)/extra/$(MODULE_NAME).ko
	sudo depmod -a
	@echo "Module uninstalled."

# Load the module
load: modules
	@echo "Loading module..."
	sudo insmod $(MODULE_NAME).ko
	@echo "Module loaded. Check dmesg for output."

# Unload the module
unload:
	@echo "Unloading module..."
	sudo rmmod $(MODULE_NAME)
	@echo "Module unloaded."

# Reload the module (unload + load)
reload: unload load

# Show module info
info: modules
	@echo "Module information:"
	modinfo $(MODULE_NAME).ko

# Check if module is loaded
status:
	@echo "Checking if module is loaded..."
	@if lsmod | grep -q $(MODULE_NAME); then \
		echo "Module $(MODULE_NAME) is loaded"; \
		lsmod | grep $(MODULE_NAME); \
	else \
		echo "Module $(MODULE_NAME) is not loaded"; \
	fi

# Show kernel log related to the module
log:
	@echo "Recent kernel messages related to AKAI EIE Pro:"
	@dmesg | tail -20 | grep -i "akai\|eie"

# Development helpers
debug: EXTRA_CFLAGS += -DDEBUG -g
debug: modules

# Check for required kernel headers
check-headers:
	@echo "Checking for kernel build environment..."
	@if [ -d "$(KERNEL_SRC)" ]; then \
		echo "✓ Kernel headers found at $(KERNEL_SRC)"; \
	else \
		echo "✗ Kernel headers not found!"; \
		echo "Install with: sudo apt install linux-headers-$$(uname -r)"; \
		exit 1; \
	fi

# Show help
help:
	@echo "Available targets:"
	@echo "  all         - Build the kernel module (default)"
	@echo "  modules     - Build the kernel module"
	@echo "  clean       - Clean build artifacts"
	@echo "  install     - Install module to system (requires root)"
	@echo "  uninstall   - Remove module from system (requires root)"
	@echo "  load        - Load the module"
	@echo "  unload      - Unload the module"
	@echo "  reload      - Unload and reload the module"
	@echo "  info        - Show module information"
	@echo "  status      - Check if module is loaded"
	@echo "  log         - Show recent kernel log messages"
	@echo "  debug       - Build with debug flags"
	@echo "  check-headers - Verify kernel headers are available"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  make                    # Build the module"
	@echo "  make load               # Build and load module"
	@echo "  make reload             # Rebuild and reload module"
	@echo "  make clean install      # Clean build and install"

# Phony targets
.PHONY: all modules clean install uninstall load unload reload info status log debug check-headers help

# Additional build flags (uncomment as needed)
# EXTRA_CFLAGS += -DDEBUG                    # Enable debug messages
# EXTRA_CFLAGS += -Wall -Wextra              # Extra warnings
# EXTRA_CFLAGS += -Werror                    # Treat warnings as errors