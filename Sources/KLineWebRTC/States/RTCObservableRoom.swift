//
//  RTCObservableRoom.swift
//  
//
//  Created by Kyaw Naing Tun on 22/12/2022.
//

import SwiftUI
import LiveKit
import AVFoundation
import Promises

import WebRTC
import CoreImage.CIFilterBuiltins
import ReplayKit

extension ObservableParticipant {

    public var mainVideoPublication: TrackPublication? {
        firstScreenSharePublication ?? firstCameraPublication
    }

    public var mainVideoTrack: VideoTrack? {
        firstScreenShareVideoTrack ?? firstCameraVideoTrack
    }

    public var subVideoTrack: VideoTrack? {
        firstScreenShareVideoTrack != nil ? firstCameraVideoTrack : nil
    }
}

public class RTCObservableRoom: ObservableRoom {

    let queue = DispatchQueue(label: "rtc.observableroom")

    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()

    @Published public var focusParticipant: ObservableParticipant?

    @Published public var textFieldString: String = ""

    override init(_ room: Room = Room()) {
        super.init(room)
        room.add(delegate: self)
    }

    @discardableResult
    public func unpublishAll() -> Promise<Void> {
        Promise(on: queue) { () -> Void in
            guard let localParticipant = self.room.localParticipant else { return }
            try awaitPromise(localParticipant.unpublishAll())
            DispatchQueue.main.async {
                self.cameraTrackState = .notPublished()
                self.microphoneTrackState = .notPublished()
                self.screenShareTrackState = .notPublished()
            }
        }
    }

    // MARK: - RoomDelegate

    override public func room(_ room: Room, didUpdate connectionState: ConnectionState, oldValue: ConnectionState) {

        super.room(room, didUpdate: connectionState, oldValue: oldValue)

        if case .disconnected = connectionState {
            DispatchQueue.main.async {
                // Reset state
                self.focusParticipant = nil
                self.textFieldString = ""
                self.objectWillChange.send()
            }
        }
    }

    override public func room(_ room: Room, participantDidLeave participant: RemoteParticipant) {
        DispatchQueue.main.async {
            // self.participants.removeValue(forKey: participant.sid)
            if let focusParticipant = self.focusParticipant,
               focusParticipant.sid == participant.sid {
                self.focusParticipant = nil
            }
            self.objectWillChange.send()
        }
    }

    override public func room(_ room: Room, participant: RemoteParticipant?, didReceive data: Data) {

        print("did receive data \(data)")
    }
}
