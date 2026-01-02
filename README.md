# Epic Pomodoro Timer

![Language](https://img.shields.io/badge/Language-Bash-blue?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Dependency](https://img.shields.io/badge/Visuals-TerminalTextEffects-orange?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-grey?style=for-the-badge)

**A high-fidelity, visual productivity timer for the command line.**

The **Epic Pomodoro Timer** is designed for developers and system administrators who require a dedicated focus tool without leaving the terminal environment. Unlike standard text-based counters, this application leverages advanced rendering techniques to display time in massive ASCII block numerals, accompanied by non-blocking visual effects and synthesized audio cues.

---

## Demo

![Application Demo](demo.gif)
*(Note: Please ensure a file named `demo.gif` is uploaded to your repository to display the preview)*

---

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Architecture](#architecture)
- [License](#license)

---

## Features

* **High-Visibility Display:** Renders time using a custom 5-line ASCII block engine, ensuring readability from a distance.
* **Asynchronous Visual Effects:** Integrates `terminaltexteffects` to produce complex animations (Thunderstorm, Beams, Matrix) that run independently of the countdown logic.
* **Synthesized Audio:** Uses `sox` to generate distinct audio profiles for initialization, ticks, warnings, and session completion—no external audio files required.
* **Non-Blocking Input Loop:** Allows users to pause, resume, or skip sessions instantly without interrupting the visual rendering pipeline.
* **State Persistence:** Automatically saves user preferences and session intervals to a local configuration file.
* **Asset Flexibility:** Supports built-in technical art, external ASCII repositories, and local image-to-ASCII conversion via `jp2a`.

---

## Prerequisites

This application relies on specific system libraries for audio synthesis and visual processing.

### Python Dependencies
The visual engine requires the `terminaltexteffects` library.

```bash
pip install terminaltexteffects
