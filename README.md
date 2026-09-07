<!--
===============================
DebSet 1.1 - VNC & Desktop Installer with Optional DE Flavors
Supports: GNOME, XFCE, LXDE, MATE, KDE, Cinnamon
===============================
MIT License
Copyright (c) 2025 Atelloblue

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
===============================
-->

# :desktop_computer: DebSet

[![GitHub stars](https://img.shields.io/github/stars/Atelloblue/DebSet?color=brightgreen)](https://github.com/Atelloblue/DebSet/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/Atelloblue/DebSet?color=brightgreen)](https://github.com/Atelloblue/DebSet/issues)
[![GitHub forks](https://img.shields.io/github/forks/Atelloblue/DebSet?color=brightgreen)](https://github.com/Atelloblue/DebSet/network)
[![made-with-bash](https://img.shields.io/badge/-Made%20with%20Bash-1f425f.svg)](https://www.gnu.org/software/bash/)

A simple script to install **VNC** with your choice of desktop environment (GNOME, XFCE, LXDE, MATE, KDE, Cinnamon) on **Debian based** computers.

> This script is unofficial and is not affiliated with any Linux desktop project.

---

## Features

- Install **TigerVNC server** automatically if not present.
- Choose your desktop environment: GNOME, XFCE, LXDE, MATE, KDE, Cinnamon.
- Set up VNC password for secure access.
- Configure VNC to start the selected desktop environment automatically.
- Optional: enable VNC to start automatically on boot via systemd.

---

## Supported Operating Systems

| OS      | Version |       |
| ------- | ------- | ----- |
| Ubuntu  | 22.04   | 🟢    |
| Ubuntu  | 24.04   | 🟢    |
| Ubuntu  | 25.04   | 🟢    |
| Debian  | 11      | 🟠    |
| Debian  | 12      | 🟠    |
| Debian  | 13      | 🟠    |
> Each is tested on GNOME.

> 🟠 = Not Tested  
> 🔴 = Not Supported  
> 🟢 = Supported

---

## Installation

Run the following one-liner as **root** or using `sudo`:

```bash
bash <(curl -s https://raw.githubusercontent.com/Atelloblue/DebSet/refs/heads/main/debset.sh)
