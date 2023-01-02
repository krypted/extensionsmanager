# extensionsmanager

## Purpose

This project is to provide telemetry into extensions on macOS. There are a few types of extensions and extensionsmman can be used to see the system extensions, network extensions (which are a class of network extensions), and the app extensions that are on a system. pluginkit and systemextensionsctl can be used to obtain some of this information if the app has been opened and the extension loaded. The goal of this project is to see the extensions that have not been loaded and provide a single interface to see information about the various types of extensions on a system.

## Usage

`extensionsman -all` to show all extensions

or

`extensionsman -thirdparty` to show thirdparty extensions

or

`extensionsman -n` to show network extensions

or

`extensionsman -s` to show system extensions except network extensions

or

`extensionsman -raw` to show unformatted result

or

`extensionsman -u` to show system extensions that haven't been loaded

or

`extensionsman -h` to show usage information

## How It Works

Built-in tools like pluginkit and systemextensionsctl can be used to see information about extensions once they've been loaded. pkd (for app extensions) and one of a few different daemons for system extensions manage them on a Mac. However, it is possible (and likely) that there are .appex and .systemextension bundles on a device that haven't yet been registered. These can live in /Applications, /Applications/Utilities, and /Library/Application Support. Therefore, in order to see which are on a system, these directories need to be searched and compared against the information obtained through pluginkit and systemextensionsctl for a more holistic view of the extensions on a device. 

Extensions have privacy implications. Apple provided the tools mentioned to give system administrators access to information on devices; however, this information is not readily available via API endpoints that can be called via swift. Therefore, while this is a swift project, some of the work being done is accessing shell commands. 

## What's next?

A GUI of course...
