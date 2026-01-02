# Epic Pomodoro Timer

![Language](https://img.shields.io/badge/Language-Bash-blue?style=for-the-badge\&logo=gnu-bash\&logoColor=white)
![Dependency](https://img.shields.io/badge/Visuals-TerminalTextEffects-orange?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-grey?style=for-the-badge)

**A high-fidelity, visual productivity timer for the command line.**

The **Epic Pomodoro Timer** is designed for developers and system administrators who want a dedicated focus tool without leaving the terminal. Unlike standard text-based counters, it renders time in massive ASCII block numerals, paired with non-blocking visual effects and synthesized audio cues.

---

## Demo

![Application Demo](demo.gif)

> **Note:** Upload a file named `demo.gif` to the repository root to display the preview.

---

## Table of Contents

* [Features](#features)
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Usage](#usage)
* [Configuration](#configuration)
* [Architecture](#architecture)
* [License](#license)
* [Acknowledgements](#acknowledgements)

---

## Features

* **High-Visibility Display:** Custom 5-line ASCII block engine for long-distance readability.
* **Asynchronous Visual Effects:** Integrates `terminaltexteffects` (Thunderstorm, Beams, Matrix) without blocking the countdown.
* **Synthesized Audio:** Uses `sox` to generate tones for start, ticks, warnings, and completion—no external audio files required.
* **Non-Blocking Input Loop:** Pause, resume, skip, or quit instantly without interrupting rendering.
* **State Persistence:** Saves preferences and session intervals to a local config file.
* **Asset Flexibility:** Built-in art, external ASCII repositories, and optional image-to-ASCII via `jp2a`.

---

## Prerequisites

This application relies on system libraries for audio synthesis and visual processing.

### Python Dependency

```bash
pip install terminaltexteffects
```

### System Packages

`sox` is required for audio generation. `jp2a` is optional (recommended for image conversion).

**Fedora / RHEL**

```bash
sudo dnf install sox jp2a
```

**Debian / Ubuntu**

```bash
sudo apt install sox libsox-fmt-all jp2a
```

**Arch Linux**

```bash
sudo pacman -S sox jp2a
```

---

## Installation

### Clone the Repository

```bash
git clone https://github.com/aayushananda/Epic-Pomodoro-Timer.git
cd Epic-Pomodoro-Timer
```

### Set Execution Permissions

```bash
chmod +x pomodoro.sh
```

### Execute the Application

```bash
./pomodoro.sh
```

---

## Usage

On startup, the application checks dependencies and launches the Setup Wizard. While running, use the following controls:

| Key | Function       | Description                                                |
| --- | -------------- | ---------------------------------------------------------- |
| P   | Pause / Resume | Suspends the timer and audio; shows a static pause screen. |
| S   | Skip           | Ends the current session and advances to the next state.   |
| Q   | Quit           | Terminates the process and cleans up temporary files.      |

---

## Configuration

User preferences are stored in `~/.pomodoro_config`.

### Setup Wizard

On first run, you’ll be prompted to configure:

* **Work Duration** (Default: 25 minutes)
* **Short Break** (Default: 5 minutes)
* **Long Break** (Default: 15 minutes)
* **ASCII Art Source** (Built-in, URL, or Local Image)

### Manual Reset

To restore defaults, remove the configuration file:

```bash
rm ~/.pomodoro_config
```

---

## Architecture

The script runs a precise loop handling three tasks per second:

1. **Time Calculation:** Computes remaining time and formats digits for the block clock.
2. **Input Polling:** Reads stdin with a 0.1s timeout for responsive controls.
3. **Render Cycle:** Clears necessary terminal lines and redraws ASCII art, clock, and controls.

This design prevents heavy visual effects (e.g., Thunderstorm animation) from causing time drift.

---

## License

Distributed under the **MIT License**. See `LICENSE` for details.

---

## Acknowledgements

* **TerminalTextEffects** by ChrisBuilds — visual engine
* **jp2a** — JPEG-to-ASCII conversion
* **Awesome-ASCII-Art** — text art repository

