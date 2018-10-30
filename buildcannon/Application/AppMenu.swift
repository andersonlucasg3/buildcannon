//
//  AppMenu.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 30/10/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class AppMenu {
    class func createMenu() -> ActionMenu {
        let options = [
            ActionMenuOption.init(command: "create", detail: "Creates the default.cannon file with basic configurations.", action: {}),
            ActionMenuOption.init(command: "create-target", detail: "Creates a 'target name'.cannon file that can be used to build that specific configuration.", action: {}),
            ActionMenuOption.init(command: "distribute", detail: "Start the archive, export, upload flow to distribute an IPA. Optionally you can provide a specific cannon file name, like ProjectName to use its configuration.", action: {}),
            ActionMenuOption.init(command: "export", detail: "Start the archive, and provides the exported IPA.", action: {}),
            ActionMenuOption.init(command: "upload", detail: "Start the upload process with the provided IPA through the parameter --ipa-path=[/path/to/ipa].", action: {}),
            ActionMenuOption.init(command: "self-update", detail: "Start the self update of the buildcannon binary. Updates to the lastest version.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.projectFile.name)=\"[projName].[xcworkspace|xcodeproj]\"", detail: "Provide a proj.xcodeproj or a space.xcworkspace to build.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.scheme.name)=\"[scheme name]\"", detail: "Provide a scheme name to build.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.configuration.name)=\"[configuration name]\"", detail: "Provide a build configuration to build.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.target.name)=\"[target name]\"", detail: "Provide a target to build.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.sdk.name)=\"[iphoneos | iphonesimulator | appletvos | appletvsimulator]\"", detail: "Provides the SDK to be used on build.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.teamId.name)=[12TEAM43ID]", detail: "Provide a Team ID to publish on.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.bundleIdentifier.name)=[com.yourcompany.app]", detail: "Provide a bundle identifier to build.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.topShelfBundleIdentifier.name)=[com.yourcompany.app.topshelf]", detail: "Provide a bundle identifier to build the TopShelf target.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.provisioningProfile.name)=\"[your provisioning profile name]\"", detail: "Provide a provisioning profile name to build.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.topShelfProvisioningProfile.name)=\"[your provisioning profile name for TopShelf]\"", detail: "Provide a provisioning profile name to build the TopShelf target.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.verbose.name)", detail: "Logs all content into the console.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.help.name)", detail: "Shows this menu with public parameters.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.archivePath.name)=\"[/path/to/archive.xcarchive]\"", detail: "If --exportOnly is specified this parameter MUST be informed.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.ipaPath.name)=\"[/path/to/ipa.ipa]\"", detail: "If --uploadOnly is specified this parameter MUST be informed.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.outputPath.name)=\"[/path/to/output.ipa]\"", detail: "If running 'buildcannon export' this parameter MUST be informed.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.exportMethod.name)=\"[app-store | ad-hoc | development | enterprise]\"", detail: "If running 'buildcannon `distribute`|`export`' export method can be specified.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.username.name)=account_name@domain.com", detail: "Specifies the AppStore Connect account (email).", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.password.name)=**********", detail: "Specifies the AppStore Connect account password.", action: {}),
            ActionMenuOption.init(command: "--\(InputParameter.version.name)", detail: "Prints the version of the installed buildcannon binary.", action: {})
        ]
        return ActionMenu.init(description: "Usage: ", options: options)
    }
}
