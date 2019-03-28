//
//  Helper.swift
//  Alarmadillo
//
//  Created by Tanner Quesenberry on 3/27/19.
//  Copyright © 2019 Tanner Quesenberry. All rights reserved.
//

import Foundation

struct Helper {
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
