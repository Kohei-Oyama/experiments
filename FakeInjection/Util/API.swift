//
//  API.swift
//  FakeInjection
//
//  Created by Kohei Oyama on 2017/10/19.
//  Copyright © 2017年 Kohei Oyama. All rights reserved.
//

import UIKit

import APIKit
import SwiftyJSON

protocol FakeInjectionRequest: Request {

}

enum PlaceURL: String {
    case lab = "http://192.168.11.23:8000"
    case home = "http://192.168.11.5:8000"
    case uTokyo = "http://10.213.200.206:8000"
}

extension FakeInjectionRequest {
    var baseURL: URL {
        get {
            return URL(string: "http://192.168.11.23:8000")!
        }
        set {
            print(newValue)
        }
    }
}

struct PostStartRequest: FakeInjectionRequest {
    typealias Response = String

    let person: String
    let reverseTime: Int
    let startTime: String
    let isModeReverse: Bool

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "start"
    }

    var parameters: Any? {
        let param: [String:String] = ["person":"\(person)","reverseTime":"\(reverseTime)","startTime":"\(startTime)","isModeReverse":"\(isModeReverse)"]
        return param
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return "OK"
    }
}

struct PostReverseRequest: FakeInjectionRequest {
    typealias Response = String

    let reverseTime: String

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "reverse"
    }

    var parameters: Any? {
        let param: [String:String] = ["reverseTime":"\(reverseTime)"]
        return param
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return "OK"
    }
}

struct PostEndRequest: FakeInjectionRequest {
    typealias Response = String

    let endTime: String

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "end"
    }

    var parameters: Any? {
        let param: [String:String] = ["endTime":"\(endTime)"]
        return param
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return "OK"
    }
}


