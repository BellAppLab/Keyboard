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

Keyboard is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Keyboard"
```

## Author

Bell App Lab, apps@bellapplab.com

## License

Keyboard is available under the MIT license. See the LICENSE file for more info.
