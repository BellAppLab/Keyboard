# Keyboard

[![CI Status](http://img.shields.io/travis/Bell App Lab/Keyboard.svg?style=flat)](https://travis-ci.org/Bell App Lab/Keyboard)
[![Version](https://img.shields.io/cocoapods/v/Keyboard.svg?style=flat)](http://cocoapods.org/pods/Keyboard)
[![License](https://img.shields.io/cocoapods/l/Keyboard.svg?style=flat)](http://cocoapods.org/pods/Keyboard)
[![Platform](https://img.shields.io/cocoapods/p/Keyboard.svg?style=flat)](http://cocoapods.org/pods/Keyboard)

## Usage

![Screenshots/Screenshot.png](Screenshots/Screenshot.png)

### Step 1:

ctrl + drag to your favorite layout constraint

### Step 2: 

Set your view controller's `handlesKeyboard` option to 'on'

### Step 3:

**Get on with your life**

======

To run the example project, clone the repo, and run `pod install` from the Example directory first.

**Please note** that the Simulator (iPhone 6s Plus / iOS 9.1 / 13B137) may not send the appropriate `UIKeyboardWillShowNotification`s. Pressing `cmd+K` while running on the Simulator may help. Nonetheless the Example app has been tested on a device running iOS 9.1 (13B143) and works. 

**Also please note** that you may get the following messages on the console (which don't affect the library in any way):

    _BSMachError: (os/kern) invalid capability (20)
    _BSMachError: (os/kern) invalid name (15)

## Requirements

iOS 8+

## Installation

### CocoaPods

Keyboard is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Keyboard"
```

### Git Submodules

**Why submodules, you ask?**

Following [this thread](http://stackoverflow.com/questions/31080284/adding-several-pods-increases-ios-app-launch-time-by-10-seconds#31573908) and other similar to it, and given that Cocoapods only works with Swift by adding the use_frameworks! directive, there's a strong case for not bloating the app up with too many frameworks. Although git submodules are a bit trickier to work with, the burden of adding dependencies should weigh on the developer, not on the user. :wink:

To install Keyboard using git submodules:

```
cd toYourProjectsFolder
git submodule add -b Submodule --name Keyboard https://github.com/BellAppLab/Keyboard.git
```

Navigate to the new Keyboard folder and drag the Pods folder to your Xcode project.

## Author

Bell App Lab, apps@bellapplab.com

## License

Keyboard is available under the MIT license. See the LICENSE file for more info.
