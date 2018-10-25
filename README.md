# KOControls

KOControls is a package of useful controls. It helps you to create a better user experience without a lot of effort.

Right now it contains only the few features but it will be getting the new stuff, depending on the users needs.

## Features

- KOPresentationQueuesService - Service manages the queues of views to present. 
- KOTextField - Text field supports showing and validating an error.
- KOScrollOffsetProgressController - Controller that calculates progress from given range based on scroll view offset and selected calculating 'mode'. 
- KODialogViewController -  High customizable dialog view, that can be used to create you own dialog in simply way.
- KODatePickerViewController - Simple way to get the date from the user.
- KOOptionsPickerViewController - Simple way to get the selected option from the user.
- KOItemsTablePickerViewController - @up .. from table.
- KOItemsCollectionPickerViewController - @up .. from collection.
- KODimmingTransition - Transition uses presentation with dimming view.
- KOVisualEffectDimmingTransition - Transition uses presentation with dimming view with visual effect.

## Requirements

* iOS 10+
* Xcode 10.0+
* Swift 4.2+

## Installation

KOControls doesn't contains any external dependencies. If you want to stay updated install KOControls by Cocoapods.

### CocoaPods

Add below entry to the target in Podfile
```
pod 'KOControls', '~> 1.0'
```
For example

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'Target Name' do
pod 'KOControls', '~> 1.0'
end
```
Install the pods by running

```
pod install
```

### Manually

You can use KOControls manually and customize how you like. One of the simplest way to do that.

1. Download repository.
2. Copy the KOControls.xcodeproj and folder Sources to the your project directory.
3. In project explorer click "Add Files to 'Your project'" -> choose KOControls.xcodeproj. Xcode will add automatically KOControls as a sub-project.
4. In project settings -> Target -> Add embeded library ->  choose 'Your project' -> KOControls.xcodeproj -> Products -> KOControls.framework.
5. And thats all! If you don't want to build KOControl manually every time when you change something. Go to the scheme settings of your target to the build section and add KOControls build target.

## Usage

You need to add following import to the top of the file.

```swift
import KOControls
```

### KOPresentationQueuesService

You can add viewController to queue of presenting, to avoid a situation when there can be multiple viewController to present at the same time, and only one will be presented.
The simplest way to add the viewController to queue of presenting is to use the overloading of function present for the presenting viewController.

```swift
let itemIdInQueue = present(viewControllerToPresent, inQueueWithIndex: messageQueueIndex)
```

The most detail one, lets you to set presenting viewController. But be careful because modalPresentationStyles that aren't presenting on current context (like custom or fullscreen) will be presented fullscreen outside the queue.

```swift
let itemIdInQueue = KOPresentationQueuesService.shared.presentInQueue(customDialog, onViewController: presentingContainerViewController, queueIndex: messageQueueIndex, animated: true, animationCompletion: nil)
```
To remove item from the queue, you need id of item in queue.

```swift
KOPresentationQueuesService.shared.removeFromQueue(withIndex: messageQueueIndex, itemWithId: itemIdInQueue)
```

Or index of item in queue.

```swift
KOPresentationQueuesService.shared.removeFromQueue(withIndex: messageQueueIndex, itemWithIndex: indexOfItemInQueue)
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
