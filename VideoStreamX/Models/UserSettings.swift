//
//  UserSettings.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/7.
//

import Foundation

extension Notification.Name {
    static let userSettingChangedNotification = NSNotification.Name("UserSettingsChanged")
    static let autoPlaySettingChanged = NSNotification.Name("AutoPlaySettingChanged")
    static let autoHideControlsSettingChanged = NSNotification.Name("AutoHideControlSettingChanged")
    static let playbackSpeedSettingChanged = NSNotification.Name("PlaybackSpeedSettingChanged")
}
enum UserSettingKey: String {
    case autoPlay
    case autoHideControls
    case playbackSpeed
}

class UserSettings: Codable {
    private var _autoPlay: Bool = true
    private var _autoHideControls: Bool = true
    private var _playbackSpeed: Float = 1.0

    var autoPlay: Bool {
        get { _autoPlay }
        set {
            if _autoPlay != newValue {
                _autoPlay = newValue
                save()
                notifySettingChanged(.autoPlay)
            }
        }
    }
    var autoHideControls: Bool {
        get { _autoHideControls }
        set {
            if _autoHideControls != newValue {
                _autoHideControls = newValue
                save()
                notifySettingChanged(.autoHideControls)
            }
        }
    }
    var playbackSpeed: Float {
        get {
            return _playbackSpeed
        }
        set {
            if _playbackSpeed != newValue {
                _playbackSpeed = newValue
                save()
                notifySettingChanged(.playbackSpeed)
            }
        }
    }

    static var shared = UserSettings()

    private static let savedKey = "userSettings"

    private init() {
        load()
    }

    func notifySettingChanged(_ key: UserSettingKey) {
        // Post a specific notification for the changed setting
        switch key {
        case .autoPlay:
            NotificationCenter.default.post(name: .autoPlaySettingChanged, object: nil)
        case .autoHideControls:
            NotificationCenter.default.post(name: .autoHideControlsSettingChanged, object: nil)
        case .playbackSpeed:
            NotificationCenter.default.post(name: .playbackSpeedSettingChanged, object: nil)
        }

        // Also post the general notification with information about which setting changed
        NotificationCenter.default.post(name: .userSettingChangedNotification,
                                        object: nil,
                                        userInfo: ["key": key])
    }
    func notifySettingsChanged() {
        NotificationCenter.default.post(name: .userSettingChangedNotification, object: nil)
    }

    func save() {
        if let encodedData = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encodedData, forKey: UserSettings.savedKey)
        }
    }

    private func load() {
        if let savedSettings = UserDefaults.standard.data(forKey: UserSettings.savedKey),
           let decodedSettings = try? JSONDecoder().decode(UserSettings.self, from: savedSettings) {
            self._autoPlay = decodedSettings._autoPlay
            self._autoHideControls = decodedSettings._autoHideControls
            self._playbackSpeed = decodedSettings._playbackSpeed
        }
    }

    enum CodingKeys: String, CodingKey {
        case _autoPlay = "autoPlay"
        case _autoHideControls = "autoHideControls"
        case _playbackSpeed = "playbackSpeed"
    }
}
