# KLineWebRTC

WebRTC Swift SDK for KLineChat

## Installation

Search and use it in your SPM `https://github.com/klinechatdev/KLineWebRTC.git`

```swift
import KLineWebRTC
```
## API Ref.

### Observable Objects

```swift
RTCAppContext
RTCRoomContext
RTCObservableRoom
```

#### RTCAppContext

To setup RTC app settings and input/output devices on initialization.

#### RTCRoomContext

To handle all of states related with room like room join/leave actions and status.

```swift
@EnvironmentObject var roomCtx: RTCRoomContext
@EnvironmentObject var appCtx: RTCAppContext
//room join
roomCtx.join(url: "wss://your_url", token: 'room_token').then { room in
    appCtx.connectionHistory.update(room: room)
}
//room leave
roomCtx.disconnect()
//access connection states
roomCtx.room.room.connectionState
// you can access the following 4 connection states
.disconnected
.connecting
.reconnecting
.connected
```

#### RTCObservableRoom

To handle all of active states in current connected.

```swift
@EnvironmentObject var room: RTCObservableRoom
//get all participants
room.allParticipants // ObservableParticipants

//get all remote participants
room.remoteParticipants // ObservableParticipants

//access local camera track state
room.cameraTrackState.isPublished //bool
room.cameraTrackState.isBusy //bool
room.toggleCameraEnabled() // camera flip

//check local microphone track state
room.microphoneTrackState.isPublished // bool
room.microphoneTrackState.isBusy //bool
room.toggleMicrophoneEnabled() // microphone on/off

//access connection states
room.room.connectionState
// you can access the following 4 connection states
.disconnected
.connecting
.reconnecting
.connected
```

## Native LiveKit APIs

#### CameraCapture Class
You can browse more about CameraCapture Class [here](https://docs.livekit.io/client-sdk-swift/CameraCapturer/).

Usage: Checks whether both front and back capturing devices exist, and can be switched.
```swift
CameraCapture.canSwitchPosition()
```

### ObservableParticipants
Related both Local and Remote participants(Track). Read more [here](https://docs.livekit.io/client-sdk-swift/ObservableParticipant/#observableparticipant.isspeaking)
