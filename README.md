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

To use Abracadabra in your own projects, simple wrap secure code:

```objc
// before
NSURLSession *session = [NSURLSession sharedSession];
NSURL *URL = [NSURL URLWithString:@"http://api.server.com/server?id=23213&action=restart"];
NSURLRequest *request = [NSURLRequest requestWithURL:URL];
NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
[task resume];

// after
SPXSecure(SPXSecurityPolicyAlwaysWithPIN, {
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

