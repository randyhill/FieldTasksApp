# FieldTasksApp

This is the front end iOS app for a client-server project written in 2017. FieldTasks was designed for 
field service workers to record client visits using location-aware forms filed for a central office. I wrote the 
server in NodeJS, it provides the reporting interface and has the form editor. 

Current State:
Project was a prototype and server is no longer running. But the app runs and you can create form templates, and save forms locally (use local target). To login just tap the Register button, it should take you right in.

Recently updated to Swift 5, but the Cocoapods I've used seem to have lots of warnings with Swift 5, haven't dug into figure out why. Project uses lots of Cocoapods to speed development

• AlamoFire for network connections

• AWS S3 for photo storage.

• FlatUIKit - Project didn't have a graphic designer yet, so used FlatUIKit (which is getting super long in the tooth) so the controls were a little more interesting to look at.

• SwiftDate - Handle processing dates in easiest manner possible.

• SVProgressHUD - Provided feedback spinner for lengthy operations. 

Local data storage is handled by Coredata, using MOGenerator to auto generate Coredata classes.

All errors or unexpected values that aren't user actionable are logged to error asserts to console. 
