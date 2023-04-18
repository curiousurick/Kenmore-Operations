// swift-tools-version:5.7
//
//  Package.swift
//
//  Copyright (c) 2022 Alamofire Software Foundation (http://alamofire.org/)
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

import PackageDescription

let package = Package(
    name: "FloatplaneApp-Operations",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
    ],
    products: [
        .library(
            name: "FloatplaneApp-Operations",
            targets: ["FloatplaneApp-Operations"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/curiousurick/FloatplaneApp-Models",
            branch: "main"
        ),
        .package(
            url: "https://github.com/curiousurick/FloatplaneApp-Utilities",
            branch: "main"
        ),
        .package(
            url: "https://github.com/curiousurick/FloatplaneApp-DataStores",
            branch: "main"
        ),
        .package(
            url: "https://github.com/Alamofire/Alamofire.git",
            from: "5.0.0"
        ),
        .package(
            url: "https://github.com/Alamofire/AlamofireImage.git",
            from: "4.2.0"
        ),
        .package(
            url: "https://github.com/WeTransfer/Mocker.git",
            from: "3.0.0"
        ),
        .package(
            url: "https://github.com/hyperoslo/Cache.git",
            from: "6.0.0"
        ),
    ],
    targets: [
        .target(
            name: "FloatplaneApp-Operations",
            dependencies: [
                "FloatplaneApp-Models",
                "FloatplaneApp-Utilities",
                "FloatplaneApp-DataStores",
                "Alamofire",
                "AlamofireImage",
                "Cache",
                "Mocker",
            ],
            path: "FloatplaneApp-Operations",
            exclude: []
        ),
        .testTarget(
            name: "FloatplaneApp-OperationsTests",
            dependencies: ["FloatplaneApp-Operations"],
            path: "FloatplaneApp-OperationsTests",
            exclude: [],
            resources: []
        ),
    ],
    swiftLanguageVersions: [.v5]
)
