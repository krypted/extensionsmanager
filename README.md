# Extensions Manager and extensionsman

To just download the graphical interface, click here https://github.com/krypted/extensionsmanager/raw/main/Extension%20Manager%20Executable.zip. 

## Purpose

This project is to provide single pane of glass telemetry into extensions on macOS. There are a few types of extensions. As such, Extensions Manager (the GUI) and extensionsmman the CLI can be used to see the system extensions, network extensions (which are a class of system extensions), and the app extensions that are on a system. `pluginkit` and `systemextensionsctl` can be used to obtain some of this information if the app has been opened and the extension loaded or known about based on the underlying daemon that manages that type of extension. The goal of this project is to see the extensions that have not been loaded and provide a single interface to see information about the various types of extensions on a system. `extensionsman` is the first of the tools (a CLI version) to aggregate information from the built-in tools from Apple about extensions. Exteensions Manager is a graphical interface that provides much of the same information but in a GUI.

<img src="https://github.com/krypted/extensionsmanager/blob/main/Images/em4.png" width="600" height="400" />

## Background

This project is loosely based on the research documented at https://krypted.com/mac-os-x/get-telemetry-on-app-and-system-extensions-in-macos/. This builds on the previous scripts at [https://github.com/krypted/extensionslist](https://github.com/krypted/extensionslist/blob/main/extensionslist.sh) and those can still be used. The new project is compiled in swift so access to the necessary entitlements can be granted via MDM at deployment time and run on client systems (like what was covered in https://krypted.com/mac-security/macos-script-to-list-system-extensions-and-their-state/ but in swift).

## Contents of the Project

This is two projects. The first is a command line interface (`extensionsman` compiled binary, extensionsman-CLI Xcode Project, and extensionsman-CLI zipped up Xcode Project) that provides information about app extensions, system extensions, and network extensions. The second is a shell for a graphical interface. This can be edited and given the open nature of the license, embedded into other products.  

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

Built-in tools like `pluginkit` and `systemextensionsctl` can be used to see information about extensions once they've been loaded. `pkd` (for app extensions) and one of a few different daemons for system extensions manage them on a Mac. However, it is possible (and likely) that there are .appex and .systemextension bundles on a device that haven't yet been registered. These can live in /Applications, /Applications/Utilities, and /Library/Application Support. Therefore, in order to see which are on a system, these directories need to be searched and compared against the information obtained through pluginkit and systemextensionsctl for a more holistic view of the extensions on a device. Just combing through the directory tree hasn't been added to the project but is planned and is available in a shell script form at https://github.com/krypted/extensionslist/blob/main/systemextensions.sh . 

Extensions have privacy implications. Apple provided the tools mentioned to give system administrators access to information on devices; however, this information is not readily available via API endpoints that can be called via swift. To quote the great Quinn "The Eskimo!" at Apple, "There is no API to get the list of system extensions installed. However, you can tell whether your system extension is installed by calling the -request:foundProperties: method." The goal is not to see if an extension is loaded from within an app but instead to see a digest of extensions. Therefore, while this is a swift project, some of the work being done is accessing shell commands (yes, shelling out to get information is dirty but sometimes it's a thing). 

## Troubleshoot Build Issues

The App Sandbox won't allow running command line tools/accessing APIs used in the project. This is why this app hasn't been submitted to the Mac App Store. The following error could appear if App Sandbox is enabled:

<img src="https://github.com/krypted/extensionsmanager/blob/main/Images/xc1.png" width="550" height="400" />

To fix, change the "Enable App Sandbox" option to No.

<img src="https://github.com/krypted/extensionsmanager/blob/main/Images/xc2.png" width="300" height="150" />

## Other Types of Extensions
Swift apps aren't the only thing on a Mac that's extensible. For more on telemetry into what Chrome Extensions are doing and to list them, see https://github.com/krypted/extensionsmanager/tree/main/Chrome%20Extensions. Keep in mind that as users use Chrome they grant more and more entitlements to the browser. For a list of Chrome extension APIs that can be consumed by basic javascripts, see https://github.com/krypted/extensionsmanager/blob/main/Chrome%20Extensions/apilist.

## What's next?

It would be great to allow for disabling and re-enabling extensions... Given that much wisdom can be found in analyzing the past, maybe it will look something like this (or later versions):

<img src="https://github.com/krypted/extensionsmanager/blob/main/Images/em3.png" width="400" height="400" />

It would be trivial to unload extensions or provide an option to delete an application bundle (or archive to a location an extension can't run at) that is used to load an extension but is currently beyond the scope of what we're trying to accomplish. We also didn't add the ability to see what apps use the extension symbols in compiled form, but instead that's at https://krypted.com/mac-os-x/new-tool-to-recursively-search-all-macos-binaries-for-symbols/ (these can take all night to run).

Because we're shelling information out it also uses a Refresh button to re-run all the scripts. It would be great to some day be able to get an entitlement that allows objects to natively work with async functions in macOS in such a way that they can be dynamically displayed (or this whole project could get sherlocked, which would be great tbh). Further GUI enhancements should eventually include a search box, the ability to sort for each column, and better dark mode support.
