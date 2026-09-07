#!/bin/bash
# ==========================================================
#   ____       _     ____       _   
#  |  _ \  ___| |__ / ___|  ___| |_ 
#  | | | |/ _ \ '_ \\___ \ / _ \ __|
#  | |_| |  __/ |_) |___) |  __/ |_ 
#  |____/ \___|_.__/|____/ \___|\__|
#
#  DebSet - Debian/Ubuntu Desktop Provisioner & Software Installer
# ==========================================================

set -u

# --- Color Scheme for Terminal Output ---
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
NC="\033[0m"

# Ensure script is run with sudo privileges available, but not root user
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}Please run DebSet as your regular user (with sudo access), NOT directly as root.${NC}"
    exit 1
fi

sudo -v # Cache sudo credentials
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null & # Keep sudo alive

# Ensure base dependencies & whiptail exist
echo -e "${BLUE}>>> [DebSet] Initializing and updating repository cache...${NC}"
sudo dpkg --add-architecture i386 # Enable 32-bit architecture for Wine/Steam
sudo apt update -y
sudo apt install -y whiptail curl wget gpg ca-certificates apt-transport-https software-properties-common

# ==========================================================
# STEP 1: DESKTOP ENVIRONMENT CHECK & INSTALLATION
# ==========================================================
CURRENT_DE="${XDG_CURRENT_DESKTOP:-}"
HAS_DE=false

if [[ -n "$CURRENT_DE" ]] || command -v gnome-session &>/dev/null || command -v startplasma-x11 &>/dev/null || \
   command -v startxfce4 &>/dev/null || command -v cinnamon-session &>/dev/null || command -v mate-session &>/dev/null || \
   command -v i3 &>/dev/null; then
    HAS_DE=true
fi

INSTALL_DE=false

if [ "$HAS_DE" = true ]; then
    if whiptail --title "DebSet | Desktop Environment" --yesno "An existing desktop environment was detected (${CURRENT_DE:-Standard Desktop}).\n\nDo you want to install an additional desktop environment or window manager?" 11 65; then
        INSTALL_DE=true
    fi
else
    whiptail --title "DebSet | No Desktop Detected" --msgbox "No Graphical Desktop Environment was detected on this system.\n\nYou will now be prompted to choose one." 10 60
    INSTALL_DE=true
fi

if [ "$INSTALL_DE" = true ]; then
    DE_CHOICE=$(whiptail --title "DebSet | Choose Desktop Environment" --radiolist \
        "Select a Desktop Environment or Window Manager:\n(Space: Select | Enter: Confirm)" 20 75 8 \
        "GNOME" "Default Ubuntu Desktop (Modern, full-featured)" ON \
        "KDE" "KDE Plasma (Highly customizable, sleek & modern)" OFF \
        "XFCE" "Lightweight, traditional & resource friendly" OFF \
        "Cinnamon" "Familiar Windows-like UI (Linux Mint default)" OFF \
        "MATE" "Classic GNOME 2 fork (Stable, lightweight)" OFF \
        "LXQt" "Extremely lightweight modern Qt desktop" OFF \
        "i3" "i3-wm (Lightweight Tiling Window Manager for power users)" OFF \
        "SKIP" "Skip desktop environment installation" OFF \
        3>&1 1>&2 2>&3)

    case "$DE_CHOICE" in
        "GNOME") sudo apt install -y ubuntu-desktop gdm3 ;;
        "KDE") sudo apt install -y kde-plasma-desktop sddm ;;
        "XFCE") sudo apt install -y xfce4 xfce4-goodies lightdm ;;
        "Cinnamon") sudo apt install -y cinnamon-desktop-environment lightdm ;;
        "MATE") sudo apt install -y mate-desktop-environment lightdm ;;
        "LXQt") sudo apt install -y lxqt sddm ;;
        "i3") sudo apt install -y i3 i3status dmenu rxvt-unicode lightdm ;;
        *) echo -e "${YELLOW}Skipping Desktop Environment installation.${NC}" ;;
    esac

    if [ "$DE_CHOICE" != "SKIP" ] && [ -n "$DE_CHOICE" ]; then
        sudo systemctl set-default graphical.target
    fi
fi

# ==========================================================
# STEP 2: WEB BROWSERS
# ==========================================================
SELECTED_BROWSERS=$(whiptail --title "DebSet | Web Browsers" --checklist \
    "Select browsers you want to install:\n(Space: Toggle | Up/Down: Scroll | Enter: Next)" 20 78 9 \
    "chrome" "Google Chrome (Standard proprietary browser)" OFF \
    "firefox" "Mozilla Firefox (Privacy-focused & open source)" OFF \
    "brave" "Brave Browser (Built-in tracker & ad blocker)" OFF \
    "edge" "Microsoft Edge (Chromium-based browser)" OFF \
    "chromium" "Chromium (Open-source foundation of Chrome)" OFF \
    "vivaldi" "Vivaldi (Power-user customization & tab stacking)" OFF \
    "opera" "Opera (Includes built-in VPN & messaging tray)" OFF \
    "tor" "Tor Browser (Maximum privacy and anonymity routing)" OFF \
    "librewolf" "LibreWolf (Hardened, telemetry-free Firefox fork)" OFF \
    3>&1 1>&2 2>&3)

# ==========================================================
# STEP 3: DEVELOPER TOOLS & RUNTIMES
# ==========================================================
SELECTED_DEV=$(whiptail --title "DebSet | Developer Tools & Languages" --checklist \
    "Select development tools & programming languages:\n(Space: Toggle | Up/Down: Scroll | Enter: Next)" 20 78 10 \
    "vscode" "Visual Studio Code (Microsoft Code Editor)" OFF \
    "docker" "Docker CE & Docker Compose Engine" OFF \
    "git_pack" "Git, Git-LFS & Build-Essential (gcc, g++, make)" ON \
    "gh_cli" "GitHub CLI (Official GitHub command line tool)" OFF \
    "python" "Python 3, Pip, Virtualenv & Header files" OFF \
    "nodejs" "NodeJS (Current LTS) & NPM package manager" OFF \
    "rust" "Rust Programming Language & Cargo via rustup" OFF \
    "golang" "Go Programming Language (Latest Apt)" OFF \
    "neovim" "Neovim (Hyperextensible modern Vim-based text editor)" OFF \
    "sublime" "Sublime Text (High performance text editor)" OFF \
    "dbeaver" "DBeaver (Universal database client for SQL/NoSQL)" OFF \
    "postman" "Postman (API development and testing platform)" OFF \
    3>&1 1>&2 2>&3)

# ==========================================================
# STEP 4: COMMUNICATION & PRODUCTIVITY
# ==========================================================
SELECTED_COMM=$(whiptail --title "DebSet | Communication & Office" --checklist \
    "Select communication tools and office suites:\n(Space: Toggle | Up/Down: Scroll | Enter: Next)" 20 78 9 \
    "libreoffice" "LibreOffice Suite (Writer, Calc, Impress, Draw)" OFF \
    "onlyoffice" "OnlyOffice Desktop (High MS Office compatibility)" OFF \
    "obsidian" "Obsidian (Markdown-based linked knowledge base)" OFF \
    "discord" "Discord (Gaming & community voice/text chat)" OFF \
    "telegram" "Telegram Desktop (Fast, cloud-based messenger)" OFF \
    "signal" "Signal Desktop (Private, end-to-end encrypted chat)" OFF \
    "slack" "Slack Desktop (Team collaboration workspace)" OFF \
    "zoom" "Zoom Workplace (Video meetings & conferencing)" OFF \
    "thunderbird" "Mozilla Thunderbird (Full featured email client)" OFF \
    3>&1 1>&2 2>&3)

# ==========================================================
# STEP 5: MEDIA, GRAPHICS & CREATIVE
# ==========================================================
SELECTED_MEDIA=$(whiptail --title "DebSet | Media & Creativity" --checklist \
    "Select multimedia players, editors, and creators:\n(Space: Toggle | Up/Down: Scroll | Enter: Next)" 20 78 9 \
    "vlc" "VLC Media Player (Plays any video/audio codec)" OFF \
    "spotify" "Spotify (Music streaming desktop client)" OFF \
    "gimp" "GIMP (Advanced photo manipulation & image editing)" OFF \
    "inkscape" "Inkscape (Professional vector graphics creation)" OFF \
    "blender" "Blender (3D modeling, animation, rendering)" OFF \
    "krita" "Krita (Digital sketching & digital painting suite)" OFF \
    "obs" "OBS Studio (Screen recording and live streaming)" OFF \
    "kdenlive" "Kdenlive (Open-source multi-track video editor)" OFF \
    "handbrake" "HandBrake (Open-source video transcoder)" OFF \
    "audacity" "Audacity (Multi-track audio recorder & editor)" OFF \
    3>&1 1>&2 2>&3)

# ==========================================================
# STEP 6: GAMING & EMULATION
# ==========================================================
SELECTED_GAMING=$(whiptail --title "DebSet | Gaming & Compatibility" --checklist \
    "Select gaming platforms and compatibility layers:\n(Space: Toggle | Up/Down: Scroll | Enter: Next)" 20 78 8 \
    "steam" "Steam (Valve gaming platform + Proton layer)" OFF \
    "lutris" "Lutris (All-in-one gaming launcher: Wine, Epic, GOG)" OFF \
    "heroic" "Heroic Games Launcher (Native GOG & Epic client)" OFF \
    "wine" "Wine & Winetricks (Run Windows software on Linux)" OFF \
    "retroarch" "RetroArch (Universal multi-system emulator frontend)" OFF \
    "mangohud" "MangoHud + GOverlay (In-game FPS/Hardware HUD overlay)" OFF \
    "prism" "Prism Launcher (Lightweight multi-instance Minecraft)" OFF \
    "protonup" "ProtonUp-Qt (Manage GE-Proton & Wine runners easily)" OFF \
    3>&1 1>&2 2>&3)

# ==========================================================
# STEP 7: PRIVACY, SECURITY & PASSWORDS
# ==========================================================
SELECTED_SECURITY=$(whiptail --title "DebSet | Privacy & Security" --checklist \
    "Select security and credential management software:\n(Space: Toggle | Up/Down: Scroll | Enter: Next)" 20 78 7 \
    "bitwarden" "Bitwarden (Secure open-source password manager)" OFF \
    "keepassxc" "KeePassXC (Local encrypted offline password vault)" OFF \
    "mullvad" "Mullvad VPN (Privacy-first VPN client)" OFF \
    "wireguard" "WireGuard (Modern, high-speed VPN kernel tooling)" OFF \
    "ufw" "UFW Firewall (Auto-configured inbound protection)" ON \
    "bleachbit" "BleachBit (Clean disk space & erase tracking data)" OFF \
    3>&1 1>&2 2>&3)

# ==========================================================
# STEP 8: SYSTEM UTILITIES, SHELL & APPEARANCE
# ==========================================================
SELECTED_UTILS=$(whiptail --title "DebSet | System & Terminal Tools" --checklist \
    "Select CLI enhancements, shells, fonts and system utilities:\n(Space: Toggle | Up/Down: Scroll | Enter: Next)" 20 78 10 \
    "flatpak" "Flatpak + Flathub App Store repo" ON \
    "cli_pack" "Modern CLI tools: htop, btop, fastfetch, tmux, 7zip, tree, fzf, bat" ON \
    "zsh_starship" "ZSH Shell + Starship Prompt (Modern terminal styling)" OFF \
    "nerd_fonts" "Nerd Fonts Pack (JetBrains Mono & FiraCode patched)" OFF \
    "ms_fonts" "Microsoft TrueType Core Fonts (Arial, Times, etc.)" OFF \
    "timeshift" "Timeshift (Automatic system restore points)" OFF \
    "tlp" "TLP Power Management (Optimizes battery life for laptops)" OFF \
    "drivers" "Proprietary Hardware Drivers (Auto-detect NVIDIA/Wi-Fi)" OFF \
    "multimedia_codecs" "Restricted Codecs (MP3, MP4, AAC, DVD playback)" OFF \
    3>&1 1>&2 2>&3)

# ==========================================================
# INSTALLATION PROCESSOR
# ==========================================================
echo -e "\n${BLUE}======================================================${NC}"
echo -e "${BLUE}>>> [DebSet] Beginning Package Installation...${NC}"
echo -e "${BLUE}======================================================${NC}\n"

is_selected() {
    local list="$1"
    local item="$2"
    [[ "$list" =~ "\"$item\"" ]]
}

# --- Flatpak (Setup first if chosen or needed by apps) ---
if is_selected "$SELECTED_UTILS" "flatpak" || is_selected "$SELECTED_SECURITY" "bitwarden" || is_selected "$SELECTED_GAMING" "heroic" || is_selected "$SELECTED_GAMING" "protonup"; then
    echo -e "${GREEN}[+] Configuring Flatpak & Flathub repository...${NC}"
    sudo apt install -y flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

# --- 1. Browsers ---
if is_selected "$SELECTED_BROWSERS" "chrome"; then
    echo -e "${GREEN}[+] Installing Google Chrome...${NC}"
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
    sudo apt install -y /tmp/chrome.deb && rm /tmp/chrome.deb
fi

if is_selected "$SELECTED_BROWSERS" "firefox"; then
    echo -e "${GREEN}[+] Installing Mozilla Firefox...${NC}"
    sudo apt install -y firefox
fi

if is_selected "$SELECTED_BROWSERS" "brave"; then
    echo -e "${GREEN}[+] Installing Brave Browser...${NC}"
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update && sudo apt install -y brave-browser
fi

if is_selected "$SELECTED_BROWSERS" "edge"; then
    echo -e "${GREEN}[+] Installing Microsoft Edge...${NC}"
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
    sudo apt update && sudo apt install -y microsoft-edge-stable
fi

if is_selected "$SELECTED_BROWSERS" "chromium"; then
    echo -e "${GREEN}[+] Installing Chromium...${NC}"
    sudo apt install -y chromium-browser 2>/dev/null || sudo apt install -y chromium
fi

if is_selected "$SELECTED_BROWSERS" "vivaldi"; then
    echo -e "${GREEN}[+] Installing Vivaldi...${NC}"
    wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor | sudo tee /usr/share/keyrings/vivaldi.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vivaldi.gpg] https://repo.vivaldi.com/archive/deb/ stable main" | sudo tee /etc/apt/sources.list.d/vivaldi.list
    sudo apt update && sudo apt install -y vivaldi-stable
fi

if is_selected "$SELECTED_BROWSERS" "opera"; then
    echo -e "${GREEN}[+] Installing Opera...${NC}"
    wget -qO- https://deb.opera.com/archive.key | gpg --dearmor | sudo tee /usr/share/keyrings/opera.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/opera.gpg] https://deb.opera.com/opera-stable/ stable non-free" | sudo tee /etc/apt/sources.list.d/opera-stable.list
    sudo apt update && sudo apt install -y opera-stable
fi

if is_selected "$SELECTED_BROWSERS" "tor"; then
    echo -e "${GREEN}[+] Installing Tor Browser Launcher...${NC}"
    sudo apt install -y torbrowser-launcher
fi

if is_selected "$SELECTED_BROWSERS" "librewolf"; then
    echo -e "${GREEN}[+] Installing LibreWolf...${NC}"
    sudo apt install -y extrepo
    sudo extrepo enable librewolf
    sudo apt update && sudo apt install -y librewolf || flatpak install -y flathub io.gitlab.librewolf-community
fi

# --- 2. Developer Tools ---
if is_selected "$SELECTED_DEV" "vscode"; then
    echo -e "${GREEN}[+] Installing Visual Studio Code...${NC}"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null
    echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
    sudo apt update && sudo apt install -y code
fi

if is_selected "$SELECTED_DEV" "docker"; then
    echo -e "${GREEN}[+] Installing Docker CE Engine...${NC}"
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list
    sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$USER"
fi

if is_selected "$SELECTED_DEV" "git_pack"; then
    echo -e "${GREEN}[+] Installing Git, Git-LFS, build compilers...${NC}"
    sudo apt install -y git git-lfs build-essential cmake
fi

if is_selected "$SELECTED_DEV" "gh_cli"; then
    echo -e "${GREEN}[+] Installing GitHub CLI (gh)...${NC}"
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
    sudo apt update && sudo apt install -y gh
fi

if is_selected "$SELECTED_DEV" "python"; then
    echo -e "${GREEN}[+] Installing Python 3 & Virtualenv ecosystem...${NC}"
    sudo apt install -y python3 python3-pip python3-venv python3-dev
fi

if is_selected "$SELECTED_DEV" "nodejs"; then
    echo -e "${GREEN}[+] Installing NodeJS (LTS)...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
fi

if is_selected "$SELECTED_DEV" "rust"; then
    echo -e "${GREEN}[+] Installing Rust & Cargo via rustup...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

if is_selected "$SELECTED_DEV" "golang"; then
    echo -e "${GREEN}[+] Installing Golang...${NC}"
    sudo apt install -y golang
fi

if is_selected "$SELECTED_DEV" "neovim"; then
    echo -e "${GREEN}[+] Installing Neovim...${NC}"
    sudo apt install -y neovim
fi

if is_selected "$SELECTED_DEV" "sublime"; then
    echo -e "${GREEN}[+] Installing Sublime Text...${NC}"
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt update && sudo apt install -y sublime-text
fi

if is_selected "$SELECTED_DEV" "dbeaver"; then
    echo -e "${GREEN}[+] Installing DBeaver CE...${NC}"
    sudo add-apt-repository -y ppa:serge-rider/dbeaver-ce
    sudo apt update && sudo apt install -y dbeaver-ce
fi

if is_selected "$SELECTED_DEV" "postman"; then
    echo -e "${GREEN}[+] Installing Postman...${NC}"
    flatpak install -y flathub com.getpostman.Postman || sudo snap install postman
fi

# --- 3. Communication & Office ---
if is_selected "$SELECTED_COMM" "libreoffice"; then
    echo -e "${GREEN}[+] Installing LibreOffice...${NC}"
    sudo apt install -y libreoffice
fi

if is_selected "$SELECTED_COMM" "onlyoffice"; then
    echo -e "${GREEN}[+] Installing OnlyOffice Desktop...${NC}"
    wget -q https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb -O /tmp/onlyoffice.deb
    sudo apt install -y /tmp/onlyoffice.deb && rm /tmp/onlyoffice.deb
fi

if is_selected "$SELECTED_COMM" "obsidian"; then
    echo -e "${GREEN}[+] Installing Obsidian...${NC}"
    flatpak install -y flathub md.obsidian.Obsidian
fi

if is_selected "$SELECTED_COMM" "discord"; then
    echo -e "${GREEN}[+] Installing Discord...${NC}"
    wget -q "https://discord.com/api/download?platform=linux&format=deb" -O /tmp/discord.deb
    sudo apt install -y /tmp/discord.deb && rm /tmp/discord.deb
fi

if is_selected "$SELECTED_COMM" "telegram"; then
    echo -e "${GREEN}[+] Installing Telegram Desktop...${NC}"
    sudo apt install -y telegram-desktop
fi

if is_selected "$SELECTED_COMM" "signal"; then
    echo -e "${GREEN}[+] Installing Signal Desktop...${NC}"
    wget -qO- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal-xenial.list
    sudo apt update && sudo apt install -y signal-desktop
fi

if is_selected "$SELECTED_COMM" "slack"; then
    echo -e "${GREEN}[+] Installing Slack...${NC}"
    flatpak install -y flathub com.slack.Slack || sudo snap install slack --classic
fi

if is_selected "$SELECTED_COMM" "zoom"; then
    echo -e "${GREEN}[+] Installing Zoom...${NC}"
    wget -q https://zoom.us/client/latest/zoom_amd64.deb -O /tmp/zoom.deb
    sudo apt install -y /tmp/zoom.deb && rm /tmp/zoom.deb
fi

if is_selected "$SELECTED_COMM" "thunderbird"; then
    echo -e "${GREEN}[+] Installing Thunderbird...${NC}"
    sudo apt install -y thunderbird
fi

# --- 4. Media & Creativity ---
if is_selected "$SELECTED_MEDIA" "vlc"; then
    echo -e "${GREEN}[+] Installing VLC...${NC}"
    sudo apt install -y vlc
fi

if is_selected "$SELECTED_MEDIA" "spotify"; then
    echo -e "${GREEN}[+] Installing Spotify...${NC}"
    curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA4D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update && sudo apt install -y spotify-client
fi

if is_selected "$SELECTED_MEDIA" "gimp"; then
    echo -e "${GREEN}[+] Installing GIMP...${NC}"
    sudo apt install -y gimp
fi

if is_selected "$SELECTED_MEDIA" "inkscape"; then
    echo -e "${GREEN}[+] Installing Inkscape...${NC}"
    sudo apt install -y inkscape
fi

if is_selected "$SELECTED_MEDIA" "blender"; then
    echo -e "${GREEN}[+] Installing Blender...${NC}"
    sudo apt install -y blender
fi

if is_selected "$SELECTED_MEDIA" "krita"; then
    echo -e "${GREEN}[+] Installing Krita...${NC}"
    sudo apt install -y krita
fi

if is_selected "$SELECTED_MEDIA" "obs"; then
    echo -e "${GREEN}[+] Installing OBS Studio...${NC}"
    sudo apt install -y obs-studio
fi

if is_selected "$SELECTED_MEDIA" "kdenlive"; then
    echo -e "${GREEN}[+] Installing Kdenlive...${NC}"
    sudo apt install -y kdenlive
fi

if is_selected "$SELECTED_MEDIA" "handbrake"; then
    echo -e "${GREEN}[+] Installing HandBrake...${NC}"
    sudo apt install -y handbrake
fi

if is_selected "$SELECTED_MEDIA" "audacity"; then
    echo -e "${GREEN}[+] Installing Audacity...${NC}"
    sudo apt install -y audacity
fi

# --- 5. Gaming & Emulation ---
if is_selected "$SELECTED_GAMING" "steam"; then
    echo -e "${GREEN}[+] Installing Steam...${NC}"
    sudo apt install -y steam-installer 2>/dev/null || sudo apt install -y steam
fi

if is_selected "$SELECTED_GAMING" "lutris"; then
    echo -e "${GREEN}[+] Installing Lutris...${NC}"
    sudo add-apt-repository -y ppa:lutris-team/lutris
    sudo apt update && sudo apt install -y lutris
fi

if is_selected "$SELECTED_GAMING" "heroic"; then
    echo -e "${GREEN}[+] Installing Heroic Games Launcher...${NC}"
    flatpak install -y flathub com.heroicgameslauncher.hgl
fi

if is_selected "$SELECTED_GAMING" "wine"; then
    echo -e "${GREEN}[+] Installing Wine & Winetricks...${NC}"
    sudo apt install -y wine winetricks
fi

if is_selected "$SELECTED_GAMING" "retroarch"; then
    echo -e "${GREEN}[+] Installing RetroArch...${NC}"
    sudo apt install -y retroarch
fi

if is_selected "$SELECTED_GAMING" "mangohud"; then
    echo -e "${GREEN}[+] Installing MangoHud & GOverlay...${NC}"
    sudo apt install -y mangohud goverlay
fi

if is_selected "$SELECTED_GAMING" "prism"; then
    echo -e "${GREEN}[+] Installing Prism Launcher (Minecraft)...${NC}"
    flatpak install -y flathub org.prismlauncher.PrismLauncher
fi

if is_selected "$SELECTED_GAMING" "protonup"; then
    echo -e "${GREEN}[+] Installing ProtonUp-Qt...${NC}"
    flatpak install -y flathub net.davidotek.pupgui2
fi

# --- 6. Privacy & Security ---
if is_selected "$SELECTED_SECURITY" "bitwarden"; then
    echo -e "${GREEN}[+] Installing Bitwarden...${NC}"
    flatpak install -y flathub com.bitwarden.desktop
fi

if is_selected "$SELECTED_SECURITY" "keepassxc"; then
    echo -e "${GREEN}[+] Installing KeePassXC...${NC}"
    sudo apt install -y keepassxc
fi

if is_selected "$SELECTED_SECURITY" "mullvad"; then
    echo -e "${GREEN}[+] Installing Mullvad VPN...${NC}"
    curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc
    echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$(dpkg --print-architecture)] https://repository.mullvad.net/deb/stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mullvad.list
    sudo apt update && sudo apt install -y mullvad-vpn
fi

if is_selected "$SELECTED_SECURITY" "wireguard"; then
    echo -e "${GREEN}[+] Installing WireGuard...${NC}"
    sudo apt install -y wireguard wireguard-tools
fi

if is_selected "$SELECTED_SECURITY" "ufw"; then
    echo -e "${GREEN}[+] Configuring UFW Firewall...${NC}"
    sudo apt install -y ufw
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw --force enable
fi

if is_selected "$SELECTED_SECURITY" "bleachbit"; then
    echo -e "${GREEN}[+] Installing BleachBit...${NC}"
    sudo apt install -y bleachbit
fi

# --- 7. System Utilities, Shell & Theming ---
if is_selected "$SELECTED_UTILS" "cli_pack"; then
    echo -e "${GREEN}[+] Installing Modern CLI Package...${NC}"
    sudo apt install -y htop btop tmux tree p7zip-full p7zip-rar unzip fzf bat ripgrep
    sudo apt install -y fastfetch 2>/dev/null || sudo apt install -y neofetch 2>/dev/null || true
fi

if is_selected "$SELECTED_UTILS" "zsh_starship"; then
    echo -e "${GREEN}[+] Setting up Zsh and Starship Prompt...${NC}"
    sudo apt install -y zsh
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
    chsh -s "$(which zsh)" "$USER" || true
fi

if is_selected "$SELECTED_UTILS" "nerd_fonts"; then
    echo -e "${GREEN}[+] Installing JetBrains Mono & FiraCode Nerd Fonts...${NC}"
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip -O /tmp/jb.zip
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip -O /tmp/fc.zip
    unzip -qo /tmp/jb.zip -d "$FONT_DIR" && unzip -qo /tmp/fc.zip -d "$FONT_DIR"
    rm /tmp/jb.zip /tmp/fc.zip
    fc-cache -f
fi

if is_selected "$SELECTED_UTILS" "ms_fonts"; then
    echo -e "${GREEN}[+] Installing Microsoft TrueType Core Fonts...${NC}"
    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections
    sudo apt install -y ttf-mscorefonts-installer
fi

if is_selected "$SELECTED_UTILS" "timeshift"; then
    echo -e "${GREEN}[+] Installing Timeshift...${NC}"
    sudo apt install -y timeshift
fi

if is_selected "$SELECTED_UTILS" "tlp"; then
    echo -e "${GREEN}[+] Installing TLP Power Optimizer...${NC}"
    sudo apt install -y tlp tlp-rdw
    sudo systemctl enable tlp
fi

if is_selected "$SELECTED_UTILS" "drivers"; then
    echo -e "${GREEN}[+] Detecting and installing proprietary drivers...${NC}"
    sudo ubuntu-drivers install 2>/dev/null || true
fi

if is_selected "$SELECTED_UTILS" "multimedia_codecs"; then
    echo -e "${GREEN}[+] Installing restricted codecs & DVD support...${NC}"
    sudo apt install -y ubuntu-restricted-extras libavcodec-extra ffmpeg || true
fi

# ==========================================================
# FINAL CLEANUP & REBOOT
# ==========================================================
echo -e "\n${BLUE}>>> [DebSet] Performing System Cleanup...${NC}"
sudo apt autoremove -y
sudo apt autoclean

if whiptail --title "DebSet | Setup Complete" --yesno "DebSet has finished configuring and installing all selected software!\n\nA system reboot is strongly recommended.\n\nWould you like to reboot now?" 12 65; then
    echo -e "${YELLOW}Rebooting system...${NC}"
    sudo reboot
else
    echo -e "${GREEN}DebSet provisioning finished. Please reboot whenever convenient!${NC}"
fi
