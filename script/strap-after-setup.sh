#!/usr/bin/env bash
set -e
trap on_sigterm SIGKILL SIGTERM

TEMP_DIR=$(mktemp -d)

function set_preferences() {
  echo "Setting some macOS system preferences..."

  # make Library directory visible
  chflags nohidden ~/Library
  # show hidden files
  defaults write com.apple.finder AppleShowAllFiles YES
  # System Preferences > General > Click in the scrollbar to: Jump to the spot that's clicked
  defaults write -globalDomain "AppleScrollerPagingBehavior" -bool true
  # System Preferences > Dock > Size:
  defaults write com.apple.dock tilesize -int 36
  # System Preferences > Dock > Magnification:
  defaults write com.apple.dock magnification -bool true
  # System Preferences > Dock > Minimize windows into application icon
  defaults write com.apple.dock minimize-to-application -bool true
  # System Preferences > Dock > Automatically hide and show the Dock:
  defaults write com.apple.dock autohide -bool true
  # System Preferences > Dock > Show indicators for open applications
  defaults write com.apple.dock show-process-indicators -bool true
  # Finder > Preferences > Show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  # Finder > Preferences > Show warning before removing from iCloud Drive
  defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false
  # Finder > View > As List
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
  # Finder > View > Show Path Bar
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder ShowStatusBar -bool true

  echo "Killing affected apps..."
  for app in "Dock" "Finder"; do
    killall "${app}" > /dev/null 2>&1
  done

  echo "Done. Note that some of these changes require a logout/restart to take effect."
  sleep 1
}

#=============== START - Shell specific stuff ==================#

function install_fish() {
    echo "Trying to detect installed Fish Shell..."

    if ! [ $(which fish) ]; then
        echo "Seems like you don't have Fish Shell installed"
        echo "Fish Shell is required to continue the installation"

        read -p "Do you agree to install it? (y/N) " -n 1 answer
        echo
        if [ ${answer} != "y" ]; then
            exit 1
        fi

        echo "Installing Fish Shell..."
        echo "The script will ask you the password for sudo 2 times:"
        echo
        echo "1) When adding fish shell into /etc/shells via tee"
        echo "2) When changing your default shell via chsh -s"

        brew install fish
    else
        echo "You already have Fish Shell installed"
        echo "Just to be sure, that this is your default shell, I'm going to call chsh..."
    fi

    echo "$(command -v fish)" | sudo tee -a /etc/shells

    echo "Fish installed!"

    sleep 1
}

function post_install() {
    echo
    echo
    echo "Setup was successfully done"
    echo
    echo "Happy Coding!"

    exit 0
}

function on_sigterm() {
    echo
    echo -e "Wow... Something serious happened!"
    exit 1
}

set_preferences
install_fish
post_install
