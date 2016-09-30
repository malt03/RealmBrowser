# RealmBrowser

[![Platform](https://img.shields.io/cocoapods/p/RealmBrowser.svg?style=flat)](http://cocoapods.org/pods/RealmBrowser)
![Language](https://img.shields.io/badge/language-Swift%203.0-orange.svg)
[![CocoaPods](https://img.shields.io/cocoapods/v/RealmBrowser.svg?style=flat)](http://cocoapods.org/pods/RealmBrowser)
![License](https://img.shields.io/github/license/malt03/RealmBrowser.svg?style=flat)

![Screenshot](https://raw.githubusercontent.com/malt03/DebugMenuRealmBrowser/master/Screenshot.gif)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

```swift
presentViewController(RealmBrowser.instantiate(moduleName: "RealmBrowser_Example"), animated: true, completion: nil)
```

### with [DebugHead](https://cocoapods.org/pods/DebugHead)
Use [DebugMenuRealmBrowser](https://cocoapods.org/pods/DebugMenuRealmBrowser).

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
  DebugMenuRealmBrowserViewController.prepare(moduleName: "<module name>")
  DebugHead.sharedInstance.prepare(menuClasses: [DebugMenuRealmBrowserViewController.self])
  return true
}
```

## Installation

RealmBrowser is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RealmBrowser"
```

## Author

Koji Murata, malt.koji@gmail.com

## License

RealmBrowser is available under the MIT license. See the LICENSE file for more info.
