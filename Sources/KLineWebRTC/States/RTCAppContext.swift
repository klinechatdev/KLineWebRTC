import SwiftUI
import LiveKit
import WebRTC
import Combine

extension ObservableObject where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
    func notify() {
        DispatchQueue.main.async { self.objectWillChange.send() }
    }
}

// This class contains the logic to control behavior of the whole app.
public class RTCAppContext: ObservableObject {

    @Published public var videoViewVisible: Bool = true

    @Published public var showInformationOverlay: Bool = false

    @Published public var preferMetal: Bool = true

    @Published public var videoViewMode: VideoView.LayoutMode = .fit

    @Published public var videoViewMirrored: Bool = false

    @Published public var connectionHistory: Set<ConnectionHistory> = []

    @Published public var outputDevice: RTCAudioDevice = RTCAudioDevice.defaultDevice(with: .output) {
        didSet {
            print("didSet outputDevice: \(String(describing: outputDevice))")

            if !Room.audioDeviceModule.setOutputDevice(outputDevice) {
                print("failed to set value")
            }
        }
    }

    @Published public var inputDevice: RTCAudioDevice = RTCAudioDevice.defaultDevice(with: .input) {
        didSet {
            print("didSet inputDevice: \(String(describing: inputDevice))")

            if !Room.audioDeviceModule.setInputDevice(inputDevice) {
                print("failed to set value")
            }
        }
    }

    @Published public var preferSpeakerOutput: Bool = false {
        didSet { AudioManager.shared.preferSpeakerOutput = preferSpeakerOutput }
    }

    public init() {
        Room.audioDeviceModule.setDevicesUpdatedHandler {
            print("devices did update")
            // force UI update for outputDevice / inputDevice
            DispatchQueue.main.async {

                // set to default device if selected device is removed
                if !Room.audioDeviceModule.outputDevices.contains(where: { self.outputDevice == $0 }) {
                    self.outputDevice = RTCAudioDevice.defaultDevice(with: .output)
                }

                // set to default device if selected device is removed
                if !Room.audioDeviceModule.inputDevices.contains(where: { self.inputDevice == $0 }) {
                    self.inputDevice = RTCAudioDevice.defaultDevice(with: .input)
                }

                self.objectWillChange.send()
            }
        }
    }
}
