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
import Kenmore_Models
@testable import Kenmore_Operations

extension BaseCreator {
    func copy(with creatorId: String) -> BaseCreator {
        BaseCreator(
            about: about,
            category: category,
            cover: cover,
            defaultChannel: defaultChannel,
            description: description,
            discoverable: discoverable,
            icon: icon,
            id: creatorId,
            incomeDisplay: incomeDisplay,
            liveStream: liveStream,
            owner: owner,
            subscriberCountDisplay: subscriberCountDisplay,
            title: title,
            urlname: urlname
        )
    }
}

extension CreatorListResponse.CreatorResponseObject {
    func copy(with creator: BaseCreator) -> CreatorListResponse.CreatorResponseObject {
        CreatorListResponse.CreatorResponseObject(
            creator: creator,
            userNotificationSetting: userNotificationSetting
        )
    }
}

class GetFirstPageOperationTest: XCTestCase {
    private let creatorRequest = TestModelSupplier.creatorRequest
    private let creator = TestModelSupplier.creator
    private let activeCreatorId = "linustechstonks"

    /// Mocks
    private var mockCreatorOperation: MockCacheableStrategyBasedOperation<CreatorRequest, Creator>!
    private var mockContentFeedOperation: MockCacheableStrategyBasedOperation<ContentFeedRequest, CreatorFeed>!
    private var mockCreatorListOperation: MockCacheableStrategyBasedOperation<CreatorListRequest, CreatorListResponse>!

    private var subject: GetFirstPageOperationImpl!

    override func setUp() {
        super.setUp()

        mockCreatorOperation = MockCacheableStrategyBasedOperation()
        mockContentFeedOperation = MockCacheableStrategyBasedOperation()
        mockCreatorListOperation = MockCacheableStrategyBasedOperation()

        // Default setup for happy case
        let firstCreatorObject = TestModelSupplier.creatorResponseObject
        let creatorListResponse = CreatorListResponse(responseObjects: [firstCreatorObject])

        let firstBaseCreator = creatorListResponse.creators[0]
        mockCreatorListOperation.mockGet = { request in
            if request == TestModelSupplier.creatorListRequest {
                return OperationResponse(response: creatorListResponse, error: nil)
            }
            return OperationResponse(response: nil, error: nil)
        }
        mockCreatorOperation.mockGet = { request in
            if request == TestModelSupplier.creatorRequest {
                return OperationResponse(response: TestModelSupplier.creator, error: nil)
            }
            return OperationResponse(response: nil, error: nil)
        }
        mockContentFeedOperation.mockGet = { request in
            if request == ContentFeedRequest.firstPage(for: firstBaseCreator.id) {
                return OperationResponse(response: TestModelSupplier.creatorFeed, error: nil)
            }
            return OperationResponse(response: nil, error: nil)
        }

        subject = GetFirstPageOperationImpl(
            creatorOperation: mockCreatorOperation,
            contentFeedOperation: mockContentFeedOperation,
            creatorListOperation: mockCreatorListOperation
        )
    }

    func testGetHappyCase_noActiveCreator() async {
        // Act
        let getFirstPageRequest = GetFirstPageRequest()
        let result = await subject.get(request: getFirstPageRequest)

        // Assert
        XCTAssertNil(result.error)
        XCTAssertNotNil(result.response)
        let response = result.response!
        let expectedCreator = TestModelSupplier.creator
        XCTAssertEqual(response.activeCreator, expectedCreator)
        let expectedBaseCreators = TestModelSupplier.creatorListResponse.creators
        XCTAssertEqual(response.baseCreators, expectedBaseCreators)
        let expectedFeed = TestModelSupplier.creatorFeed
        XCTAssertEqual(response.firstPage, expectedFeed.items)

        XCTAssertEqual(mockCreatorListOperation.getCallCount, 1)
        XCTAssertEqual(mockCreatorOperation.getCallCount, 1)
        XCTAssertEqual(mockContentFeedOperation.getCallCount, 1)
    }

    func testGetHappyCase_nilActiveCreator() async {
        // Act
        let getFirstPageRequest = GetFirstPageRequest(activeCreatorId: nil)
        let result = await subject.get(request: getFirstPageRequest)

        // Assert
        XCTAssertNil(result.error)
        XCTAssertNotNil(result.response)
        let response = result.response!
        let expectedCreator = TestModelSupplier.creator
        XCTAssertEqual(response.activeCreator, expectedCreator)
        let expectedBaseCreators = TestModelSupplier.creatorListResponse.creators
        XCTAssertEqual(response.baseCreators, expectedBaseCreators)
        let expectedFeed = TestModelSupplier.creatorFeed
        XCTAssertEqual(response.firstPage, expectedFeed.items)

        XCTAssertEqual(mockCreatorListOperation.getCallCount, 1)
        XCTAssertEqual(mockCreatorOperation.getCallCount, 1)
        XCTAssertEqual(mockContentFeedOperation.getCallCount, 1)
    }

    func testGetHappyCase_withActiveCreator() async {
        // Arrange
        let firstCreatorObject = TestModelSupplier.creatorResponseObject
        let activeBaseCreator = firstCreatorObject.creator.copy(with: activeCreatorId)
        let secondCreatorObject = firstCreatorObject.copy(with: activeBaseCreator)
        let expectedBaseCreators = [firstCreatorObject.creator, secondCreatorObject.creator]
        let creatorListResponse = CreatorListResponse(responseObjects: [firstCreatorObject, secondCreatorObject])
        mockCreatorListOperation.mockGet = { request in
            if request == TestModelSupplier.creatorListRequest {
                return OperationResponse(response: creatorListResponse, error: nil)
            }
            return OperationResponse(response: nil, error: nil)
        }
        mockContentFeedOperation.mockGet = { request in
            if request == ContentFeedRequest.firstPage(for: self.activeCreatorId) {
                return OperationResponse(response: TestModelSupplier.creatorFeed, error: nil)
            }
            return OperationResponse(response: nil, error: nil)
        }

        // Act
        let getFirstPageRequest = GetFirstPageRequest(activeCreatorId: activeCreatorId)
        let result = await subject.get(request: getFirstPageRequest)

        // Assert
        XCTAssertNil(result.error)
        XCTAssertNotNil(result.response)
        let response = result.response!
        let expectedCreator = TestModelSupplier.creator
        XCTAssertEqual(response.activeCreator, expectedCreator)
        XCTAssertEqual(response.baseCreators, expectedBaseCreators)
        let expectedFeed = TestModelSupplier.creatorFeed
        XCTAssertEqual(response.firstPage, expectedFeed.items)

        XCTAssertEqual(mockCreatorListOperation.getCallCount, 1)
        XCTAssertEqual(mockCreatorOperation.getCallCount, 1)
        XCTAssertEqual(mockContentFeedOperation.getCallCount, 1)
    }

    func testGetHappyCase_withActiveCreator_noMatchPicksFirst() async {
        // Arrange
        let firstCreatorObject = TestModelSupplier.creatorResponseObject
        let activeBaseCreator = firstCreatorObject.creator.copy(with: "unknownActiveCreatorId")
        let secondCreatorObject = firstCreatorObject.copy(with: activeBaseCreator)
        let expectedBaseCreators = [firstCreatorObject.creator, secondCreatorObject.creator]
        let creatorListResponse = CreatorListResponse(responseObjects: [firstCreatorObject, secondCreatorObject])
        mockCreatorListOperation.mockGet = { request in
            if request == TestModelSupplier.creatorListRequest {
                return OperationResponse(response: creatorListResponse, error: nil)
            }
            return OperationResponse(response: nil, error: nil)
        }
        mockContentFeedOperation.mockGet = { request in
            if request == ContentFeedRequest.firstPage(for: firstCreatorObject.creator.id) {
                return OperationResponse(response: TestModelSupplier.creatorFeed, error: nil)
            }
            return OperationResponse(response: nil, error: nil)
        }

        // Act
        let getFirstPageRequest = GetFirstPageRequest(activeCreatorId: activeCreatorId)
        let result = await subject.get(request: getFirstPageRequest)

        // Assert
        XCTAssertNil(result.error)
        XCTAssertNotNil(result.response)
        let response = result.response!
        let expectedCreator = TestModelSupplier.creator
        XCTAssertEqual(response.activeCreator, expectedCreator)
        XCTAssertEqual(response.baseCreators, expectedBaseCreators)
        let expectedFeed = TestModelSupplier.creatorFeed
        XCTAssertEqual(response.firstPage, expectedFeed.items)

        XCTAssertEqual(mockCreatorListOperation.getCallCount, 1)
        XCTAssertEqual(mockCreatorOperation.getCallCount, 1)
        XCTAssertEqual(mockContentFeedOperation.getCallCount, 1)
    }

    func testGetCreatorListOpFails() async {
        // Arrange
        let error = TestingError.reallyBad
        mockCreatorListOperation.mockGet = { request in
            if request == TestModelSupplier.creatorListRequest {
                return OperationResponse(response: nil, error: error)
            }
            return OperationResponse(response: nil, error: nil)
        }

        let getFirstPageRequest = GetFirstPageRequest()

        // Act
        let result = await subject.get(request: getFirstPageRequest)

        // Assert
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.response)
        XCTAssertTrue(result.error is TestingError)
        let resultantError = result.error as! TestingError
        XCTAssertEqual(resultantError, error)

        XCTAssertEqual(mockCreatorListOperation.getCallCount, 1)
        XCTAssertEqual(mockCreatorOperation.getCallCount, 0)
        XCTAssertEqual(mockContentFeedOperation.getCallCount, 0)
    }

    func testGetCreatorOpFails() async {
        // Arrange
        let error = TestingError.reallyBad
        mockCreatorOperation.mockGet = { request in
            if request == TestModelSupplier.creatorRequest {
                return OperationResponse(response: nil, error: error)
            }
            return OperationResponse(response: nil, error: nil)
        }

        let getFirstPageRequest = GetFirstPageRequest()

        // Act
        let result = await subject.get(request: getFirstPageRequest)

        // Assert
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.response)
        XCTAssertTrue(result.error is TestingError)
        let resultantError = result.error as! TestingError
        XCTAssertEqual(resultantError, error)

        XCTAssertEqual(mockCreatorListOperation.getCallCount, 1)
        XCTAssertEqual(mockCreatorOperation.getCallCount, 1)
        XCTAssertEqual(mockContentFeedOperation.getCallCount, 1)
    }

    func testGetContentFeedOpFails() async {
        // Arrange
        let creatorListResponse = TestModelSupplier.creatorListResponse
        let activeBaseCreator = creatorListResponse.creators[0]
        let error = TestingError.reallyBad
        mockContentFeedOperation.mockGet = { request in
            if request == ContentFeedRequest.firstPage(for: activeBaseCreator.id) {
                return OperationResponse(response: nil, error: error)
            }
            return OperationResponse(response: nil, error: nil)
        }

        let getFirstPageRequest = GetFirstPageRequest()

        // Act
        let result = await subject.get(request: getFirstPageRequest)

        // Assert
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.response)
        XCTAssertTrue(result.error is TestingError)
        let resultantError = result.error as! TestingError
        XCTAssertEqual(resultantError, error)

        XCTAssertEqual(mockCreatorListOperation.getCallCount, 1)
        XCTAssertEqual(mockCreatorOperation.getCallCount, 1)
        XCTAssertEqual(mockContentFeedOperation.getCallCount, 1)
    }

    func testIsActive_creatorListActive() {
        // Arrange
        mockCreatorListOperation.mockIsActive = true

        // Act
        let result = subject.isActive()

        // Assert
        XCTAssertTrue(result)
        XCTAssertEqual(mockCreatorListOperation.isActiveCallCount, 1)
        XCTAssertEqual(mockCreatorOperation.isActiveCallCount, 0)
        XCTAssertEqual(mockContentFeedOperation.isActiveCallCount, 0)
    }

    func testIsActive_creatorOpActive() {
        // Arrange
        mockCreatorOperation.mockIsActive = true

        // Act
        let result = subject.isActive()

        // Assert
        XCTAssertTrue(result)
        XCTAssertEqual(mockCreatorListOperation.isActiveCallCount, 1)
        XCTAssertEqual(mockCreatorOperation.isActiveCallCount, 1)
        XCTAssertEqual(mockContentFeedOperation.isActiveCallCount, 0)
    }

    func testIsActive_contentFeedOpIsActive() {
        // Arrange
        mockContentFeedOperation.mockIsActive = true

        // Act
        let result = subject.isActive()

        // Assert
        XCTAssertTrue(result)
        XCTAssertEqual(mockCreatorListOperation.isActiveCallCount, 1)
        XCTAssertEqual(mockCreatorOperation.isActiveCallCount, 1)
        XCTAssertEqual(mockContentFeedOperation.isActiveCallCount, 1)
    }

    func testIsActive_noneActive() {
        // Act
        let result = subject.isActive()

        // Assert
        XCTAssertFalse(result)
        XCTAssertEqual(mockCreatorListOperation.isActiveCallCount, 1)
        XCTAssertEqual(mockCreatorOperation.isActiveCallCount, 1)
        XCTAssertEqual(mockContentFeedOperation.isActiveCallCount, 1)
    }

    func testCancel_cancellsAll() {
        // Act
        subject.cancel()

        // Assert
        XCTAssertEqual(mockCreatorListOperation.cancelCallCount, 1)
        XCTAssertEqual(mockCreatorOperation.cancelCallCount, 1)
        XCTAssertEqual(mockContentFeedOperation.cancelCallCount, 1)
    }
}
