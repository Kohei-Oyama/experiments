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

extension FakeInjectionRequest {
    var baseURL: URL {
        let url: String = "http://192.168.11.9:8000"
        return URL(string: url)!
    }
}

struct PostStartRequest: FakeInjectionRequest {
    typealias Response = String

    let person: String
    let reverseTime: Int
    let startTime: String

    var method: HTTPMethod {
        return .post
    }

    var path: String {
        return "start"
    }

    var parameters: Any? {
        let param: [String:String] = ["person":"\(person)","reverseTime":"\(reverseTime)","startTime":"\(startTime)"]
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


