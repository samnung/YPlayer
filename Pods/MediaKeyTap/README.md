# MediaKeyTap

`MediaKeyTap` provides an API for accessing the Mac's media keys (play/pause, next and previous) in your Swift application.
`MediaKeyTap` will only capture key events when it is the most recently activated media application, matching the behaviour of
existing applications, such as those using `SPMediaKeyTap`.

`MediaKeyTap` builds its whitelist by combining the static whitelist from `SPMediaTap` with a dynamic whitelist built
at runtime using `NSDistributedNotificationCenter`. If you create a new application using this library, you should not
need to add your bundle identifier to the whitelist.

## Usage

Create a `MediaKeyTap`:
```swift
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    ⋮

    var mediaKeyTap: MediaKeyTap?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        mediaKeyTap = MediaKeyTap(delegate: self)
        mediaKeyTap?.start()
    }

    ⋮
}
```

and implement `MediaKeyTapDelegate`'s 1 method:
```swift
func handleMediaKey(mediaKey: MediaKey, event: KeyEvent) {
    switch mediaKey {
    case .PlayPause:
        print("Play/pause pressed")
    case .Previous, .Rewind:
        print("Previous pressed")
    case .Next, .FastForward:
        print("Next pressed")
    }
}
```

You can also access the `KeyEvent` to access the event's underlying `keycode`, `keyFlags` and `keyRepeat` values.

The MediaKeyTap initialiser allows the keypress behaviour to be specified:
```swift
    MediaKeyTap(delegate: self, on: .KeyDown) // Default
    MediaKeyTap(delegate: self, on: .KeyUp)
    MediaKeyTap(delegate: self, on: .KeyDownAndUp)
```

## Requirements

* In order to capture key events globally, your application cannot be sandboxed or you will not receive any events.

## Installation

### CocoaPods

Add `pod 'MediaKeyTap'` to your `Podfile` and run `pod install`.

Then `import MediaKeyTap`.

### Carthage

Add `github "nhurden/MediaKeyTap"` to your `Cartfile` and run `carthage update`.
