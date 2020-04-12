#  jwin - just what I need

An app that has just the things I need.

Provides a tabbed view of some "sub-apps" that are not really related, but having them in the same app is nice.

App data is stored as a single JSON document (which it should eventually be possible to upload/download to some cloud provider for integration with other front-ends)

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

Just stuff for debugging on the device.

## To-do

* Graceful schema migration
* Proper timezone handling for reminders
* Cloud storage

