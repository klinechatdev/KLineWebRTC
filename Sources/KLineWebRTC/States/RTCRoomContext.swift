import SwiftUI
import LiveKit
import WebRTC
import Promises

// This class contains the logic to control behavior of the whole app.
public class RTCRoomContext: ObservableObject {

    private let store: ValueStore<Preferences>

    // Used to show connection error dialog
    // private var didClose: Bool = false
    @Published public var shouldShowError: Bool = false
    public var latestError: Error?

    public let room = RTCObservableRoom()

    @Published public var url: String = "" {
        didSet { store.value.url = url }
    }

    @Published public var token: String = "" {
        didSet { store.value.token = token }
    }

    // RoomOptions
    @Published public var simulcast: Bool = true {
        didSet { store.value.simulcast = simulcast }
    }

    @Published public var adaptiveStream: Bool = false {
        didSet { store.value.adaptiveStream = adaptiveStream }
    }

    @Published public var dynacast: Bool = false {
        didSet { store.value.dynacast = dynacast }
    }

    @Published public var reportStats: Bool = false {
        didSet { store.value.reportStats = reportStats }
    }

    // ConnectOptions
    @Published public var autoSubscribe: Bool = true {
        didSet { store.value.autoSubscribe = autoSubscribe}
    }

    @Published public var publish: Bool = false {
        didSet { store.value.publishMode = publish }
    }

    public init(store: ValueStore<Preferences>) {
        self.store = store
        room.room.add(delegate: self)

        store.onLoaded.then { preferences in
            self.url = preferences.url
            self.token = preferences.token
            self.simulcast = preferences.simulcast
            self.adaptiveStream = preferences.adaptiveStream
            self.dynacast = preferences.dynacast
            self.reportStats = preferences.reportStats
            self.autoSubscribe = preferences.autoSubscribe
            self.publish = preferences.publishMode
        }

        #if os(iOS)
        UIApplication.shared.isIdleTimerDisabled = true
        #endif
    }

    deinit {
        #if os(iOS)
        UIApplication.shared.isIdleTimerDisabled = false
        #endif
        print("RoomContext.deinit")
    }

    public func connect(entry: ConnectionHistory? = nil) -> Promise<Room> {

        if let entry = entry {
            url = entry.url
            token = entry.token
        }

        let connectOptions = ConnectOptions(
            autoSubscribe: !publish && autoSubscribe, // don't autosubscribe if publish mode
            publishOnlyMode: publish ? "publish_\(UUID().uuidString)" : nil
        )

        let roomOptions = RoomOptions(
            defaultCameraCaptureOptions: CameraCaptureOptions(
                dimensions: .h1080_169
            ),
            defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(
                dimensions: .h1080_169,
                useBroadcastExtension: true
            ),
            defaultVideoPublishOptions: VideoPublishOptions(
                simulcast: publish ? false : simulcast
            ),
            adaptiveStream: adaptiveStream,
            dynacast: dynacast,
            reportStats: reportStats
        )

        return room.room.connect(url,
                                 token,
                                 connectOptions: connectOptions,
                                 roomOptions: roomOptions)
    }
    
    public func join(url: String, token: String) -> Promise<Room> {

        let connectOptions = ConnectOptions(
            autoSubscribe: !publish && autoSubscribe, // don't autosubscribe if publish mode
            publishOnlyMode: publish ? "publish_\(UUID().uuidString)" : nil
        )

        let roomOptions = RoomOptions(
            defaultCameraCaptureOptions: CameraCaptureOptions(
                dimensions: .h1080_169
            ),
            defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(
                dimensions: .h1080_169,
                useBroadcastExtension: true
            ),
            defaultVideoPublishOptions: VideoPublishOptions(
                simulcast: publish ? false : simulcast
            ),
            adaptiveStream: adaptiveStream,
            dynacast: dynacast,
            reportStats: reportStats
        )

        return room.room.connect(url,
                                 token,
                                 connectOptions: connectOptions,
                                 roomOptions: roomOptions)
    }

    public func disconnect() {
        room.room.disconnect()
    }
}

extension RTCRoomContext: RoomDelegate {

    public func room(_ room: Room, didUpdate connectionState: ConnectionState, oldValue: ConnectionState) {

        print("Did update connectionState \(connectionState) \(room.connectionState)")

        if let error = connectionState.disconnectedWithError {
            latestError = error
            DispatchQueue.main.async {
                self.shouldShowError = true
            }
        }

        DispatchQueue.main.async {
            withAnimation {
                self.objectWillChange.send()
            }
        }
    }
}
