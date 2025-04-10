# Hyper-V Toggle Script

This PowerShell script provides a graphical user interface (GUI) to toggle the state of the Hyper-V Virtual Machine Management Service (`vmms`). It allows you to start or stop the service with a single click.

## Features

- **Auto-Elevation**: Automatically requests administrator privileges if not already elevated.
- **Custom GUI**: A lightweight, custom-designed window with:
  - A title bar with minimize and close buttons.
  - A status label showing the current state of the service.
  - A toggle button to start or stop the service.
    
  ![image](https://github.com/user-attachments/assets/8b5dcdf5-94a7-4f2b-a6e4-6c8f4962eb16)

- **Service Control**:
  - Starts and enables the service if it is stopped.
  - Stops and disables the service if it is running.
- **Visual Feedback**: Updates the GUI to reflect the current state of the service.

## Prerequisites

- Windows operating system with PowerShell installed.
- Administrator privileges to control the Hyper-V service.
- Hyper-V feature enabled on your system.

## How to Use

1. Save the script as `toggle-VM-PSHELL.ps1`.
2. Run the script in PowerShell:
   ```powershell
   powershell.exe -File "path\to\toggle-VM-PSHELL.ps1"
