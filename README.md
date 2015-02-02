# Abracadabra

[![CI Status](http://img.shields.io/travis/Shaps Mohsenin/Abracadabra.svg?style=flat)](https://travis-ci.org/Shaps Mohsenin/Abracadabra)
[![Version](https://img.shields.io/cocoapods/v/Abracadabra.svg?style=flat)](http://cocoadocs.org/docsets/Abracadabra)
[![License](https://img.shields.io/cocoapods/l/Abracadabra.svg?style=flat)](http://cocoadocs.org/docsets/Abracadabra)
[![Platform](https://img.shields.io/cocoapods/p/Abracadabra.svg?style=flat)](http://cocoadocs.org/docsets/Abracadabra)

## What is it?

Abracadabra was designed for a personal project of mine. An app called [Drizzle](https://itunes.apple.com/app/drizzle/id683629145?mt=8).  Drizzle is an application for managing server instances. As you can imagine this is the kind of app that requires tight control over user actions to avoid accidental shutdowns or worse. Not to mention foul play by a 3rd party.

This was an existing project, so I didn't want to modify lots of existing code possibly introducing further issues and less stability. 

So I set out to design a truly plug 'n' play solution that made it super easy to wrap my code and gain all the benefits of passcode security (_including TouchID_).

__Introducing Abracadabra!__

>The name refers to the magical nature of its implementation as well as the fact a passcode (_or magical phrase_) is required ;)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

To use Abracadabra in your own projects, simply wrap your code with a secure block.

Lets say you have some code like this:

```objc
NSURLSession *session = [NSURLSession sharedSession];
NSURL *URL = [NSURL URLWithString:@"http://api.server.com/server?id=23213&action=restart"];
NSURLRequest *request = [NSURLRequest requestWithURL:URL];
NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
[task resume];
```

We can easily secure that code now by wrapping it with Abracadabra. Magic!

```objc
SPXSecure(SPXSecurityPolicyAlwaysWithPIN, {
  NSURLSession *session = [NSURLSession sharedSession];
  NSURL *URL = [NSURL URLWithString:@"http://api.server.com/server?id=23213&action=restart"];
  NSURLRequest *request = [NSURLRequest requestWithURL:URL];
  NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
  [task resume];
})
```

If you're happy with the default view controllers and behaviour, __that's literally it ;)__

Sometimes however, you want to provide a nice little UI to your users to allow them to control the security policy applied to individual actions right?

Well that's easy too, just add a group and event name to your secure code blocks and Abracadabra will handle the rest for you!

```objc
SPXSecure(@"Servers", @"Restart Server", SPXSecurityPolicyAlwaysWithPIN, {
  NSURLSession *session = [NSURLSession sharedSession];
  NSURL *URL = [NSURL URLWithString:@"http://api.server.com/server?id=23213&action=restart"];
  NSURLRequest *request = [NSURLRequest requestWithURL:URL];
  NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
  [task resume];
})
```

## Advanced Configurations

Abracadabra has been designed to be quite flexible and takes care of all the security for you. 

Out of the box the following areas can be customized:

* Passcode input view controller (_who says you need 4 digits?_)
* Event security policies view controller
* Passcode validation 
* Session policies (_timeout, retries, etc..._)
* more...

See the example project for full demo's on how to use all of these features.

## Under the Hood

Under the hood, the library is responsible for saving your passcode to the keychain, comparing entries, tracking retries, presenting passcode entry, and much, much more...

One of the key features however, exists in how Abracadabra can discover all of the secure events in your code and present a nice view of this, allowing the user to modify the policy applied to each event at runtime. In fact, Abracadabra even persists this information automatically across launches ;)

__So how does this work?__

This part of the code is actually based on an idea I got from [FBTweaks](https://github.com/facebook/Tweaks). Facebook demonstrated a great implementation whereby you can store some data in the binary at compile time.

Abracadabra uses the Mach-O Runtime to find this data and automatically construct a store of events. The view controllers can then simply query this store to present some user interface for configuring their policies. 

Policies for each event are then stored in `NSUserDefaults`, which allows us to persist changes across launches of the application.

When you create a secure event, you must specify the default policy to apply to that piece of code. You can also reset an event (or all events) back to their defaults at any time, since this value is stored at compile time and is readonly at runtime.

>All views and controllers can be replaced with your own implementations if you prefer.

>Abracadabra does _NOT_ use blocks! All code is guaranteed to execute on the calling thread.

## Installation

Abracadabra is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod 'Abracadabra'

## Author

Shaps Mohsenin, [shapsuk@me.com](mailto:shapsuk@me.com)

## License

Abracadabra is available under the MIT license. See the LICENSE file for more info.

## Attribution

[FXKeychain](https://github.com/nicklockwood/FXKeychain) by Nick Lockwood is used for storing your passcode securely in the Keychain.