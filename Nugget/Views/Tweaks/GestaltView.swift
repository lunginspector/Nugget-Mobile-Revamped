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
    
    struct ResolutionPreset: Identifiable, Hashable, Equatable {
        let id = UUID()
        let name: String
        let width: Int
        let height: Int
    }
         
    @State private var selectedPreset: ResolutionPreset? = nil
    @State private var enableCustomResolution: Bool = false
    @State private var resolutionPresets: [ResolutionPreset] = [
        ResolutionPreset(name: "iPhone 16 Pro Max", width: 1320, height: 2868),
        ResolutionPreset(name: "iPhone 16 Pro", width: 1206, height: 2622),
        ResolutionPreset(name: "iPhone 16", width: 1179, height: 2556),
        ResolutionPreset(name: "iPhone 15/16 Plus", width: 1290, height: 2796),
        ResolutionPreset(name: "iPhone 14/15 Pro Max", width: 1290, height: 2796),
        ResolutionPreset(name: "iPhone 15 & 14/15 Pro", width: 1179, height: 2556),
        ResolutionPreset(name: "iPhone 14 Plus/13 Pro Max", width: 1284, height: 2778),
        ResolutionPreset(name: "iPhone 12/12 Pro, 13/13 Pro, & 14", width: 1170, height: 2532),
        ResolutionPreset(name: "iPhone 12/13 mini", width: 1080, height: 2340),
        ResolutionPreset(name: "iPhone XS Max/11 Pro Max", width: 1242, height: 2688),
        ResolutionPreset(name: "iPhone X, XS, & 11 Pro", width: 1125, height: 2436),
        ResolutionPreset(name: "iPhone XR/11", width: 828, height: 1792)
    ]
    
    @State private var CurrentSubType: Int = -1
    @State private var CurrentSubTypeDisplay: String = "Default"
    
    @State private var modifyResolution: Bool = false
    private let resMode: Int = MobileGestaltManager.shared.getRdarFixMode()
    private let resTitle: String = MobileGestaltManager.shared.getRdarFixTitle()
    
    @State private var deviceModelChanged: Bool = false
    @State private var deviceModelName: String = ""
    
    @State private var customMGAKey: String = ""
    @State private var customMGAValue: String = ""
    @State private var showMGAAlert: Bool = false
    @State private var alertMGAMessage: String = ""
    @State private var addedKeys: [String: String] = [:]
    
    @State private var customWidth: String = ""
    @State private var customHeight: String = ""
    @State private var isCustomResolutionSet: Bool = false
    @State private var isResolutionChangerEnabled: Bool = false
    @State private var isCustomResolutionEnabled: Bool = false
    @State private var setResolutionButtonColor: Color = .blue

    // list of device subtype options
    @State var deviceSubTypes: [DeviceSubType] = [
        .init(key: -1, title: NSLocalizedString("Default", comment: "default device subtype")),
        .init(key: 2436, title: NSLocalizedString("Notched Gestures", comment: "x gestures")),
        .init(key: 2556, title: NSLocalizedString("Dynamic Island - iPhone 14 Pro", comment: "iPhone 14 Pro SubType")),
        .init(key: 2796, title: NSLocalizedString("Dynamic Island - iPhone 14 Pro Max", comment: "iPhone 14 Pro Max SubType")),
        .init(key: 2622, title: NSLocalizedString("Dynamic Island - iPhone 16 Pro", comment: "iPhone 16 Pro SubType"), minVersion: Version(string: "18.0")),
        .init(key: 2868, title: NSLocalizedString("Dynamic Island - iPhone 16 Pro Max", comment: "iPhone 16 Pro Max SubType"), minVersion: Version(string: "18.0")),
        .init(key: 2976, title: NSLocalizedString("Disable Dynamic Island - Island Phones ONLY", comment: "iPhone 15 Pro Max SubType"), minVersion: Version(string: "17.0"))
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
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .padding(.trailing, 6)
                        .font(.system(.title))
                        .foregroundStyle(.black)
                    Text("**Warning:** Some of these tweaks may be problematic, including **Internal** and **iPadOS**.")
                        .foregroundStyle(.black)
                }
                .listRowBackground(Color.yellow)
                .padding(.vertical, 4)
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
                    Toggle("\(resTitle) (Changes Resolution)", isOn: $modifyResolution).onChange(of: modifyResolution, perform: { nv in
                        if nv {
                            gestaltManager.setGestaltValue(key: "IOMobileGraphicsFamily", value: resMode)
                        } else {
                            gestaltManager.setGestaltValue(key: "IOMobileGraphicsFamily", value: 0)
                        }
                    })
                }
                
                // device model name
                VStack {
                    Toggle("Rename Device", isOn: $deviceModelChanged).onChange(of: deviceModelChanged, perform: { nv in
                        if nv {
                            if deviceModelName != "" {
                                gestaltManager.setGestaltValue(key: "ArtworkDeviceProductDescription", value: deviceModelName)
                            }
                        } else {
                            gestaltManager.removeGestaltValue(key: "ArtworkDeviceProductDescription")
                        }
                    })
                    
                    if deviceModelChanged {
                        TextField("New Device Name", text: $deviceModelName).onChange(of: deviceModelName, perform: { nv in
                            if deviceModelChanged {
                                gestaltManager.setGestaltValue(key: "ArtworkDeviceProductDescription", value: deviceModelName)
                            }
                        })
                    }
                }
            } header: {
                Label("Gestures & Model Name", systemImage: "platter.filled.top.and.arrow.up.iphone")
            }
            // MARK: Resolution Setter
            Section {
                Toggle("Modify Resolution", isOn: $isResolutionChangerEnabled)
                
                if isResolutionChangerEnabled {
                    if UIDevice.current.userInterfaceIdiom != .pad {
                        Picker("Preset", selection: $selectedPreset) {
                            ForEach(resolutionPresets) { preset in
                                Text(preset.name).tag(preset as ResolutionPreset?)
                            }
                        }
                        .onChange(of: selectedPreset) { newPreset in
                            if let preset = newPreset {
                                customWidth = String(preset.width)
                                customHeight = String(preset.height)
                                //gestaltManager.setGestaltValue(key: "CustomResolution", value: (preset.width, preset.height))
                            }
                        }
                    } else {
                        // Nothing will be shown
                    }
                    
                    Toggle("Set Custom Resolution", isOn: $isCustomResolutionEnabled)
                    
                    if isCustomResolutionEnabled {
                        TextField("Width", text: $customWidth)
                        TextField("Height", text: $customHeight)
                    }
                    
                    
                    Button(action: {
                        if !customWidth.isEmpty && !customHeight.isEmpty {
                            if let width = Int(customWidth), let height = Int(customHeight) {
                                gestaltManager.setGestaltValue(key: "CustomResolution", value: (width, height))
                                isCustomResolutionSet = true
                                setResolutionButtonColor = .green
                            }
                        }
                    }) {
                        if isCustomResolutionSet == true {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Resolution Set")
                            }
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "crop")
                                Text("Set Resolution")
                            }
                        }
                    }
                    .frame(maxHeight: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .buttonStyle(TintedButton(color: setResolutionButtonColor, fullwidth: true))
                    .buttonStyle(TintedButton(material: .systemMaterial, fullwidth: false))
                }
            } header: {
                Label("Resolution Setter", systemImage: "eye.square.fill")
            } footer: {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    Text("**WARNING:** Unless you know **exactly** what you are doing, don't set a custom resolution. This can easily break on iPads and it will make the device impossible to interact with.")
                } else {
                    Text("**WARNING:** Unless you know what you are doing, do not set a custom resolution. It has the ability to brick your device if you do not put in the right values.")
                }
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
            // MARK: Custom MobileGestalt Keys
            Section {
                TextField("Key", text: $customMGAKey)
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled(true)
                TextField("Value", text: $customMGAValue)
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled(true)
                Button(action: {
                    if customMGAKey.isEmpty || customMGAValue.isEmpty {
                        alertMGAMessage = "Please input a vaild MGA key and value."
                        showMGAAlert = true
                    } else {
                        if let value = Int(customMGAValue) {
                            gestaltManager.setGestaltValue(key: customMGAKey, value: value)
                        } else {
                            gestaltManager.setGestaltValue(key: customMGAKey, value: customMGAValue)
                        }
                        addedKeys[customMGAKey] = customMGAValue
                        customMGAKey = ""
                        customMGAValue = ""
                        alertMGAMessage = "Added Key"
                        showMGAAlert = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Key")
                    }
                }
                .frame(maxHeight: 45)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .buttonStyle(TintedButton(color: .blue, fullwidth: true))
                .buttonStyle(TintedButton(material: .systemMaterial, fullwidth: false))
                .alert(isPresented: $showMGAAlert) {
                    Alert(title: Text("Custom Keys"), message: Text(alertMGAMessage), dismissButton: .default(Text("OK")))
                }
            } header : {
                Label("Custom MGA Keys", systemImage: "key.fill")
            } footer : {
                Text("If you do not know what this feature does, do not touch it. You will bootloop your device if you do not use this feature properly.")
            }
            Section {
                if addedKeys.isEmpty {
                    Text("No keys have been added.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(addedKeys.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            Text(key)
                                .fontWeight(.bold)
                            Spacer()
                            Text(value)
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let keyToRemove = addedKeys.sorted(by: { $0.key < $1.key })[index].key
                            addedKeys.removeValue(forKey: keyToRemove)
                            gestaltManager.removeGestaltValue(key: keyToRemove)
                        }
                    }
                }
            } header: {
                Label("Added Keys & Values", systemImage: "list.bullet")
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
                let newAction = UIAlertAction(title: type.title, style: .default) { (action) in
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
