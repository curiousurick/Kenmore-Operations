//  Copyright © 2023 George Urick
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import XCTest
#if canImport(UIKit)
    import UIKit
#endif
#if canImport(AppKit)
    import AppKit
#endif
import AlamofireImage
@testable import Kenmore_Operations

final class ImageCacheConfigTest: XCTestCase {
    private var subject: ImageCacheConfig!

    override func setUp() {
        subject = ImageCacheConfig.instance
    }

    func testSetup() {
        // Act
        subject.setup(diskSpaceMB: 50)

        // Assert
        let expectedCapacity = 50 * 1024 * 1024
        assertCacheSize(expectedCapacity: expectedCapacity)

        // Test that it doesn't change if setup again
        subject.setup(diskSpaceMB: 1500)
        assertCacheSize(expectedCapacity: expectedCapacity)
    }

    private func assertCacheSize(expectedCapacity: Int) {
        #if canImport(UIKit)
            let urlCache = UIImageView.af.sharedImageDownloader.session.sessionConfiguration.urlCache
            let diskCapacity = urlCache?.diskCapacity
            let memoryCapacity = urlCache?.memoryCapacity

            XCTAssertEqual(diskCapacity, expectedCapacity)
            XCTAssertEqual(memoryCapacity, expectedCapacity)
        #endif
    }
}
