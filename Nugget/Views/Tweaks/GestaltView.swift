//
//  GestaltView.swift
//  Nugget
//
//  Created by lemin on 9/9/24.
//

import SwiftUI

struct GestaltView: View {
    let gestaltManager = MobileGestaltManager.shared
    let userVersion = Version(string: UIDevice.current.systemVersion)
    
    struct GestaltTweak: Identifiable {
        var id = UUID()
        var label: String
        var keys: [String]
        var values: [Any] = [1]
        var active: Bool = false
        var minVersion: Version = Version(string: "1.0")
    }
    
    struct GestaltSection: Identifiable {
        var id = UUID()
        var headerText: String
        var headerIcon: String
        var tweaks: [GestaltTweak]
    }
    
    struct DeviceSubType: Identifiable {
        var id = UUID()
        var key: Int
        var title: String
        var minVersion: Version = Version(string: "16.0")
    }
    
    @State private var CurrentSubType: Int = -1
    @State private var CurrentSubTypeDisplay: String = "Default"
    
    @State private var modifyResolution: Bool = false
    private let resMode: Int = MobileGestaltManager.shared.getRdarFixMode()
    private let resTitle: String = MobileGestaltManager.shared.getRdarFixTitle()
    
    @State private var deviceModelChanged: Bool = false
    @State private var deviceModelName: String = ""
    
    // list of device subtype options
    @State var deviceSubTypes: [DeviceSubType] = [
        .init(key: -1, title: NSLocalizedString("Default", comment: "default device subtype")),
        .init(key: 2436, title: NSLocalizedString("iPhone X Gestures", comment: "x gestures")),
        .init(key: 2556, title: NSLocalizedString("iPhone 14 Pro Dynamic Island", comment: "iPhone 14 Pro SubType")),
        .init(key: 2796, title: NSLocalizedString("iPhone 14 Pro Max Dynamic Island", comment: "iPhone 14 Pro Max SubType")),
        .init(key: 2976, title: NSLocalizedString("iPhone 15 Pro Max Dynamic Island", comment: "iPhone 15 Pro Max SubType"), minVersion: Version(string: "17.0")),
        .init(key: 2622, title: NSLocalizedString("iPhone 16 Pro Dynamic Island", comment: "iPhone 16 Pro SubType"), minVersion: Version(string: "18.0")),
        .init(key: 2868, title: NSLocalizedString("iPhone 16 Pro Max Dynamic Island", comment: "iPhone 16 Pro Max SubType"), minVersion: Version(string: "18.0"))
    ]
    
    // list of mobile gestalt tweaks
    @State var gestaltTweaks: [GestaltSection] = [
        .init(headerText: "Feature Enablers", headerIcon: "apps.iphone.badge.plus", tweaks: [
            .init(label: "Always On Display", keys: ["2OOJf1VhaM7NxfRok3HbWQ", "j8/Omm6s1lsmTDFsXjsBfA"], values: [1, 1], minVersion: Version(string: "18.0")),
            .init(label: "Boot Chime", keys: ["QHxt+hGLaBPbQJbXiUJX3w"]),
            .init(label: "Charge Limit", keys: ["37NVydb//GP/GrhuTN+exg"]),
            .init(label: "Tap to Wake", keys: ["yZf3GTRMGTuwSV/lD7Cagw"]),
        ]),
        .init(headerText: "iPadOS Features", headerIcon: "ipad", tweaks: [
            .init(label: "Stage Manager", keys: ["qeaj75wk3HF4DwQ8qbIi7g"], values: [1]),
            .init(label: "Medusa (iPad Multitasking)", keys: ["mG0AnH/Vy1veoqoLRAIgTA", "UCG5MkVahJxG1YULbbd5Bg", "ZYqko/XM5zD3XBfN5RmaXA", "nVh/gwNpy7Jv1NOk00CMrw", "uKc7FPnEO++lVhHWHFlGbQ"], values: [1, 1, 1, 1, 1]),
            .init(label: "Allow iPad Apps on iPhone", keys: ["9MZ5AdH43csAUajl/dU+IQ"], values: [[1, 2]]),
        ]),
        .init(headerText: "Settings", headerIcon: "gear", tweaks: [
            .init(label: "Collision SOS", keys: ["HCzWusHQwZDea6nNhaKndw"]),
            .init(label: "Camera Button", keys: ["CwvKxM2cEogD3p+HYgaW0Q", "oOV1jhJbdV3AddkcCg0AEA"], values: [1, 1], minVersion: Version(string: "18.0")),
            .init(label: "Apple Pencil", keys: ["yhHcB0iH0d1XzPO/CFd3ow"]),
            .init(label: "Toggle Action Button", keys: ["cT44WE1EohiwRzhsZ8xEsw"])
        ]),
        .init(headerText: "Miscellaeuous", headerIcon: "plus.diamond.fill", tweaks: [
            .init(label: "Disable Wallpaper Parallax", keys: ["UIParallaxCapability"], values: [0]),
            .init(label: "Disable Region Restrictions", keys: ["h63QSdBCiT/z0WU6rdQv6Q", "zHeENZu+wbg7PUprwNwBWg"], values: ["US", "LL/A"]),
        ]),
        .init(headerText: "Internal", headerIcon: "ant.fill", tweaks: [
            .init(label: "Toggle Internal Storage", keys: ["LBJfwOEzExRxzlAnSuI7eg"]),
            .init(label: "Apple Internal Install", keys: ["EqrsVvjcYDdxHBiQmGhAWw"]),
        ])
    ]
    
    var body: some View {
        List {
            Section {
                // warning
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .padding(.trailing, 6)
                        .font(.system(size: 25, weight: .regular, design: .default))
                        .foregroundStyle(.yellow)
                    Text("**Warning:** Some of these tweaks may cause issues with your device, mainly **Internal** and **iPadOS**.")
                }
            }
            Section {
                // device subtype
                HStack {
                    Text("Gestures & Dynamic Island")
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    Button(CurrentSubTypeDisplay, action: {
                        showSubTypeChangerPopup()
                    })
                    .foregroundColor(.blue)
                    .padding(.leading, 10)
                }
                
                // rdar fix (change resolution)
                if resMode > 0 {
                    Toggle("\(resTitle) (modifies resolution)", isOn: $modifyResolution).onChange(of: modifyResolution, perform: { nv in
                        if nv {
                            gestaltManager.setGestaltValue(key: "IOMobileGraphicsFamily", value: resMode)
                        } else {
                            gestaltManager.setGestaltValue(key: "IOMobileGraphicsFamily", value: 0)
                        }
                    })
                }
                
                // device model name
                VStack {
                    Toggle("Device Model Name", isOn: $deviceModelChanged).onChange(of: deviceModelChanged, perform: { nv in
                        if nv {
                            if deviceModelName != "" {
                                gestaltManager.setGestaltValue(key: "ArtworkDeviceProductDescription", value: deviceModelName)
                            }
                        } else {
                            gestaltManager.removeGestaltValue(key: "ArtworkDeviceProductDescription")
                        }
                    })
                    TextField("Custom Text", text: $deviceModelName).onChange(of: deviceModelName, perform: { nv in
                        if deviceModelChanged {
                            gestaltManager.setGestaltValue(key: "ArtworkDeviceProductDescription", value: deviceModelName)
                        }
                    })
                }
            } header: {
                Label("Gestures & Model Name", systemImage: "platter.filled.top.and.arrow.up.iphone")
            }
            // tweaks from list
            ForEach($gestaltTweaks) { category in
                Section(header: HStack {
                    Image(systemName: category.headerIcon.wrappedValue)
                    Text(category.headerText.wrappedValue)
                }) {
                    ForEach(category.tweaks) { tweak in
                        if userVersion >= tweak.minVersion.wrappedValue {
                            Toggle(tweak.label.wrappedValue, isOn: tweak.active).onChange(of: tweak.active.wrappedValue, perform: { nv in
                                if nv {
                                    gestaltManager.setGestaltValues(keys: tweak.keys.wrappedValue, values: tweak.values.wrappedValue)
                                } else {
                                    gestaltManager.removeGestaltValues(keys: tweak.keys.wrappedValue)
                                }
                            })
                        }
                    }
                }
            }
        }
        .tweakToggle(for: .MobileGestalt)
        .navigationTitle("MobileGestalt")
        .navigationViewStyle(.stack)
        .onAppear {
            // get the base device subtype
            for (i, deviceSubType) in deviceSubTypes.enumerated() {
                if deviceSubType.key == -1 {
                    deviceSubTypes[i].key = gestaltManager.deviceSubType
                    break
                }
            }
            // load enabled gestalt tweaks
            let enabledTweaks = gestaltManager.getEnabledTweaks()
            // first, the dynamic island
            if let subtype = enabledTweaks["ArtworkDeviceSubType"] as? Int {
                CurrentSubType = subtype
                for deviceSubType in deviceSubTypes {
                    if deviceSubType.key == subtype {
                        CurrentSubTypeDisplay = deviceSubType.title
                        break
                    }
                }
            }
            // second, the resolution
            if let resChange = enabledTweaks["IOMobileGraphicsFamily"] as? Bool {
                modifyResolution = resChange
            }
            // next, the device model name
            if let modelName = enabledTweaks["ArtworkDeviceProductDescription"] as? String {
                deviceModelName = modelName
                deviceModelChanged = true
            }
            // finally, do the other values
            for (i, category) in gestaltTweaks.enumerated() {
                for (j, gestaltTweak) in category.tweaks.enumerated() {
                    if gestaltTweak.keys.count > 0 && enabledTweaks[gestaltTweak.keys[0]] != nil {
                        gestaltTweaks[i].tweaks[j].active = true
                    }
                }
            }
        }
    }
    
    func showSubTypeChangerPopup() {
        // create and configure alert controller
        let alert = UIAlertController(title: NSLocalizedString("Choose a device subtype", comment: ""), message: "", preferredStyle: .actionSheet)
        
        // create the actions
        
        for type in deviceSubTypes {
            if userVersion >= type.minVersion {
                let newAction = UIAlertAction(title: type.title + " (" + String(type.key) + ")", style: .default) { (action) in
                    // apply the type
                    gestaltManager.setGestaltValue(key: "ArtworkDeviceSubType", value: type.key)
                    CurrentSubType = type.key
                    CurrentSubTypeDisplay = type.title
                }
                if CurrentSubType == type.key {
                    // add a check mark
                    newAction.setValue(true, forKey: "checked")
                }
                alert.addAction(newAction)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
            // cancels the action
        }
        
        // add the actions
        alert.addAction(cancelAction)
        
        let view: UIView = UIApplication.shared.windows.first!.rootViewController!.view
        // present popover for iPads
        alert.popoverPresentationController?.sourceView = view // prevents crashing on iPads
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0) // show up at center bottom on iPads
        
        // present the alert
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
}
