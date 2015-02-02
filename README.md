# Abracadabra

[![CI Status](http://img.shields.io/travis/Shaps Mohsenin/Abracadabra.svg?style=flat)](https://travis-ci.org/Shaps Mohsenin/Abracadabra)
[![Version](https://img.shields.io/cocoapods/v/Abracadabra.svg?style=flat)](http://cocoadocs.org/docsets/Abracadabra)
[![License](https://img.shields.io/cocoapods/l/Abracadabra.svg?style=flat)](http://cocoadocs.org/docsets/Abracadabra)
[![Platform](https://img.shields.io/cocoapods/p/Abracadabra.svg?style=flat)](http://cocoadocs.org/docsets/Abracadabra)

## What is it?

A simple and easy to use library for securing your code. 
The name refers to the magical nature or its implementation as well as the fact a passcode (or magical phrase) is required. ;)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

To use Abracadabra in your own projects, simple wrap secure code.

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

## Installation

Abracadabra is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod 'Abracadabra'

## Author

Shaps Mohsenin, shapsuk@me.com

## License

Abracadabra is available under the MIT license. See the LICENSE file for more info.

