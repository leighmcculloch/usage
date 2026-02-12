APP_NAME := Usage
BUILD_DIR := build
APP_BUNDLE := $(BUILD_DIR)/$(APP_NAME).app
INSTALL_DIR := $(HOME)/Applications

.PHONY: build app install uninstall clean

build: clean
	swift build -c release

app: build
	swift scripts/generate-icon.swift
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp .build/release/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/$(APP_NAME)
	cp Info.plist $(APP_BUNDLE)/Contents/Info.plist
	cp build/AppIcon.icns $(APP_BUNDLE)/Contents/Resources/

install: app
	mkdir -p $(INSTALL_DIR)
	cp -R $(APP_BUNDLE) $(INSTALL_DIR)/$(APP_NAME).app
	open $(INSTALL_DIR)/$(APP_NAME).app

uninstall:
	rm -rf $(INSTALL_DIR)/$(APP_NAME).app
	rm -f $(HOME)/Library/LaunchAgents/com.usage.plist
	@echo "Uninstalled $(APP_NAME)"

clean:
	rm -rf $(BUILD_DIR)
	swift package clean
