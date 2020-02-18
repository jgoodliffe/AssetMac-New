//
//  MainToolbar.swift
//  Production Manager Pro
//
//  Created by Jamie Goodliffe on 17/02/2020.
//  Copyright © 2020 Jamie Goodliffe. All rights reserved.
//

import Cocoa

class MainToolbar: NSToolbar, NSToolbarDelegate {
    var toolbarItems: [[String:String]] = [
        ["title": "Back", "icon": "back", "identifier": "BackToolbarItem"],
        ["title": "Add", "icon": "add", "identifier": "AddToolbarItem"],
        ["title": "Dashboard", "icon": "dashboard", "identifier": "DashboardToolbarItem"],
        ["title": "Inventory", "icon": "inventory", "identifier": "InventoryToolbarItem"],
        ["title": "Calendar", "icon": "calendar", "identifier": "CalendarToolbarItem"],
        ["title": "Manage Users", "icon": "users", "identifier": "UsersToolbarItem"],
        ["title": "Change Password", "icon": "password", "identifier": "PasswordResetToolbarItem"],
        ["title": "Log Out", "icon": "logout", "identifier": "LogoutToolbarItem"],
        ["title": "Settings", "icon": "settings", "identifier": "SettingsToolbarItem"],
    ]
    
    var toolbarTabsIdentifiers: [NSToolbarItem.Identifier] {
        return toolbarItems
            .compactMap { $0["identifier"] }
            .map{ NSToolbarItem.Identifier(rawValue: $0) }
    }
    
    /**
     Resizes images.
     */
    func resize(image: NSImage, w: Int, h: Int) -> NSImage {
        let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        return NSImage(data: newImage.tiffRepresentation!)!
    }
    
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        guard let infoDictionary: [String : String] = toolbarItems.filter({ $0["identifier"] == itemIdentifier.rawValue }).first
            else { return nil }

        let toolbarItem: NSToolbarItem
        toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        toolbarItem.label = infoDictionary["title"]!
        toolbarItem.paletteLabel = infoDictionary["title"]!
        toolbarItem.toolTip = infoDictionary["title"]!
        let iconImage = resize(image: NSImage(named: infoDictionary["icon"] ?? "")!, w: 16, h: 16)
        let button = NSButton(frame: NSRect(x: 0, y: 0, width: 40, height: 40))
        button.title = ""
        button.image = iconImage
        button.bezelStyle = .texturedRounded
        toolbarItem.view = button
        return toolbarItem
    }
    
    @objc func toolbarAction(_ sender: Any?){
        print("Received!")
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarTabsIdentifiers;
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }

    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }

    func toolbarWillAddItem(_ notification: Notification) {
        print("toolbarWillAddItem", (notification.userInfo?["item"] as? NSToolbarItem)?.itemIdentifier ?? "")
    }

    func toolbarDidRemoveItem(_ notification: Notification) {
        print("toolbarDidRemoveItem", (notification.userInfo?["item"] as? NSToolbarItem)?.itemIdentifier ?? "")
    }
}
