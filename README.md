# KLineWebRTC

WebRTC Swift SDK for KLineChat

## Example App

Browse to [example](https://github.com/klinechatdev/klinewebrtc-swift-example) project repo.

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

To handle all of states related with room like room join/leave actions and status before connected to the room.

```swift
@EnvironmentObject var roomCtx: RTCRoomContext
@EnvironmentObject var appCtx: RTCAppContext
//room join
roomCtx.join(url: "wss://your_url", token: 'room_token').then { room in
    appCtx.connectionHistory.update(room: room)
}

//room leave
roomCtx.disconnect()

//handle room connection error
roomCtx.shouldShowError // bool
roomCtx.latestError // error message

//access connection states
roomCtx.room.room.connectionState
// you can access the following 4 connection states
.disconnected
.connecting
.reconnecting
.connected
```

#### RTCObservableRoom

To handle all of active states after connected in the room.

```swift
@EnvironmentObject var room: RTCObservableRoom
//get all participants both Local and Remote
room.allParticipants // ObservableParticipants

// read more about the ObservableParticipants at the following section

//get all remote participants
room.remoteParticipants // ObservableParticipants

//access local camera track state
room.cameraTrackState.isPublished //bool
room.cameraTrackState.isBusy //bool
room.toggleCameraEnabled() // camera on/off
room.switchCameraPosition() // camera flip (back cam <> front cam)

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

Import the LiveKit to use native APIs.
```swift
import LiveKit
```
#### CameraCapture Class
You can browse more about CameraCapture Class [here](https://docs.livekit.io/client-sdk-swift/CameraCapturer/).

Usage: Checks whether both front and back capturing devices exist, and can be switched.
```swift
CameraCapture.canSwitchPosition()
```

### ObservableParticipants
Related both Local and Remote participants. You can access status/events like `isSpeaking` and more events from Participants. Read more [here](https://docs.livekit.io/client-sdk-swift/ObservableParticipant/)

### SwiftUIVideoView

[Read more](https://docs.livekit.io/client-sdk-swift/SwiftUIVideoView/)

### VideoView

[Read more](https://docs.livekit.io/client-sdk-swift/VideoView/)