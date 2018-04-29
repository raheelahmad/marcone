//
//  Utils.swift
//  App
//
//  Created by Raheel Ahmad on 4/25/18.
//

func tryOrNil<ReturnType>(f: (() throws -> ReturnType?)) -> ReturnType? {
    if let res = try? f() {
        return res
    }
    return nil
}
