//
//  File.swift
//  
//
//  Created by Kyaw Naing Tun on 22/12/2022.
//

import SwiftUI
import KeychainAccess
import Combine
import LiveKit
import Promises

public struct Preferences: Codable, Equatable {
    public var url = ""
    public var token = ""

    // Connect options
    public var autoSubscribe = true
    public var publishMode = false

    // Room options
    public var simulcast = true
    public var adaptiveStream = true
    public var dynacast = true
    public var reportStats = true

    // Settings
    public var videoViewVisible = true
    public var showInformationOverlay = false
    public var preferMetal = true
    public var videoViewMode: VideoView.LayoutMode = .fit
    public var videoViewMirrored = false

    public var connectionHistory = Set<ConnectionHistory>()
}

let encoder = JSONEncoder()
let decoder = JSONDecoder()

// Promise version
extension Keychain {

    @discardableResult
    public func get<T: Decodable>(_ key: String) -> Promise<T?> {
        Promise(on: .global()) { () -> T? in
            guard let data = try self.getData(key) else { return nil }
            return try decoder.decode(T.self, from: data)
        }
    }

    @discardableResult
    public func set<T: Encodable>(_ key: String, value: T) -> Promise<Void> {
        Promise(on: .global()) { () -> Void in
            let data = try encoder.encode(value)
            try self.set(data, key: key)
        }
    }
}

public class ValueStore<T: Codable & Equatable>: ObservableObject {

    public let store: Keychain
    public let key: String
    public let message = ""
    public weak var timer: Timer?

    public let onLoaded = Promise<T>.pending()

    public var value: T {
        didSet {
            guard oldValue != value else { return }
            lazySync()
        }
    }

    public var storeWithOptions: Keychain {
        store
            .accessibility(.whenUnlocked)
            .synchronizable(true)
    }

    public init(store: Keychain, key: String, `default`: T) {
        self.store = store
        self.key = key
        self.value = `default`

        storeWithOptions.get(key).then { (result: T?) -> Void in
            self.value = result ?? self.value
            self.onLoaded.fulfill(self.value)
        }
    }

    deinit {
        timer?.invalidate()
    }

    public func lazySync() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1,
                                     repeats: false,
                                     block: { _ in self.sync() })
    }

    public func sync() {
        storeWithOptions.set(key, value: value).catch { error in
            print("Failed to write in Keychain, error: \(error)")
        }
    }
}
