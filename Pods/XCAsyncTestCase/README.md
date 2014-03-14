Overview
-------

Allows testing of asynchronous APIs using XCTest much like [gh-unit](https://github.com/gabriel/gh-unit).

For questions or issues, please email [premosystems](https://github.com/premosystems).

Install
-------

Add `XCTestCase+AsyncTesting.h` and `XCTestCase+AsyncTesting.m` to your project.

Usage
-----

1. Add `#import "XCTestCase+AsyncTesting.h"` to tests that need to be asynchronous.
2. Create your test cases as usual
3. Call `-waitForStatus:timeout:` or `-waitForTimeout:` after you start your asynchronous call
4. Call `-notify:` in your callbacks

See `AsyncXCTestingKitTests.m` for more information.

Known Problems
--------------

* Tests hang when run under XCode build bots

LICENSE
-------

This code is licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

Copyright (c) 2011 Masashi Ono.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


KEYWORDS
--------

XCTest, XCTestCase, Asynchronous, XCode 5, Developer Preview, iOS 7, GHUnit, SenTest, Objective C
