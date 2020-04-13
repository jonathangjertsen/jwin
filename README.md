#  jwin - just what I need

An app that has just the things I need.

Provides a tabbed view of some "sub-apps" that are not really related, but having them in the same app is nice.

App data is stored as a single JSON document and can be backed up to Firebase through the debug view.

## Sub-apps

### List of lists

Simple to-do list functionality

* Any number of lists
* Each element has one line of text and may be marked as active or inactive
* No support for anything else (nested lists etc)

### Reminders

Reminder functionality

* A single list of reminders
* Sends notifications

### Debug

* Stuff for debugging on the device
* Login and cloud backup of the app state

## To-do

* Upload newest version to cloud in the background at a reasonable interval

## Setup

Prerequisites: XCode, cocoapods

* Clone the repo
* Go to the created directory and run `pod install`s
* Firebase setup ([nice Youtube guide here](https://www.youtube.com/watch?v=P1cNScXGlVI))
    * Create a new Firebase project
    * Develop --> Database --> Enable Firestore
    * Develop --> Database --> Rules --> Set some rules that at least require a logged-in user, optionally with a specific email etc
    * Develop --> Authentication --> Enable Email/Password
    * Settings --> Project settings --> Add iOS app
    * Fill in the form and place the `GoogleService-info.plist` into the top-level directory.
* Open the workspace in XCode (`open jwin.xcworkspace`)
* Launch

## CLI

Currently nonfunctional Python CLI interface to the same data
