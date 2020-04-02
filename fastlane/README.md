fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
### setup
```
fastlane setup
```
Steps taken to setup the project after initial clone; only needs to be ran once
### populate_default_data
```
fastlane populate_default_data
```
Populates default data onto your keyset
### setup_keys
```
fastlane setup_keys
```
Sets PubNub keys from ENV variables inside the project 
### lint
```
fastlane lint
```
Lints the project source files
### test
```
fastlane test
```
Executes Unit Tests

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
