# extensionsmanager

## Purpose

This project is to provide single pane of glass telemetry into extensions on macOS. There are a few types of extensions. As such, extensionsmman can be used to see the system extensions, network extensions (which are a class of system extensions), and the app extensions that are on a system. `pluginkit` and `systemextensionsctl` can be used to obtain some of this information if the app has been opened and the extension loaded or known about based on the underlying daemon that manages that type of extension. The goal of this project is to see the extensions that have not been loaded and provide a single interface to see information about the various types of extensions on a system.

## Contents of the Project

This is two projects. The first is a command line interface (`extensionsman` compiled binary, extensionsman-CLI Xcode Project, and extensionsman-CLI zipped up Xcode Project) that provides information about app extensions, system extensions, and network extensions. The second is a shell for a graphical interface (not yet uploaded at the moment). 

The source of each is posted, so they can be altered and compiled based on further needs.

## Command Line Usage

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

Built-in tools like `pluginkit` and `systemextensionsctl` can be used to see information about extensions once they've been loaded. `pkd` (for app extensions) and one of a few different daemons for system extensions manage them on a Mac. However, it is possible (and likely) that there are .appex and .systemextension bundles on a device that haven't yet been registered. These can live in /Applications, /Applications/Utilities, and /Library/Application Support. Therefore, in order to see which are on a system, these directories need to be searched and compared against the information obtained through pluginkit and systemextensionsctl for a more holistic view of the extensions on a device. Just combing through the directory tree hasn't been added to the project but is planned.

Extensions have privacy implications. Apple provided the tools mentioned to give system administrators access to information on devices; however, this information is not readily available via API endpoints that can be called via swift. Therefore, while this is a swift project, some of the work being done is accessing shell commands (yes, shelling out to get information is dirty but sometimes it's a thing). 

## What's next?

A GUI of course... Maybe for free on the app store for simpler access, but still with a compiled binary and source here for customizability. The project currently only provides information about existing extensions and doesn't have any options to manage extensions. It would be trivial to unload extensions or provide an option to delete an application bundle that is used to load an extension but is currently beyond the scope of what we're trying to accomplish. 
