//
//  main.swift
//  embeddedresourcetool
//
//  Created by Michael Rockhold on 7/20/24.
//

import Foundation
import MachOKit // Convenient means by which to load the segment/section metadata from our binary, or any MachO binary

struct SectionFileInfo {
    let name: String
    let offset: Int
    let size: Int
}

extension MachORepresentable {
    // Convenience for capturing the file offsets and data lengths of all the sections in the binary.
    // We only want the information about our custom "myinfo" section in this program, though.
    func asDictionary() -> [String:[String:SectionFileInfo]] {
        var acc = [String:[String:SectionFileInfo]]()
        for segment in segments {
            acc[segment.segmentName] = [String:SectionFileInfo]()
        }
        for section in sections {
            (acc[section.segmentName]!)[section.sectionName] = SectionFileInfo(name: section.sectionName, offset: section.offset, size: section.size)
        }
        return acc
    }
}

print("Here is the absolute path to the currently-running binary:")
print(ProcessInfo.processInfo.arguments[0])

let filePath =  ProcessInfo.processInfo.arguments[0]
let myURL = URL(fileURLWithPath: filePath)

let file = try MachOKit.loadFromFile(url: myURL)
guard case .machO(let machO) = file else { exit(-1) }

let d = machO.asDictionary()

// "__myinfo" is an entirely arbitrary name I just made up. In your code, you will want to avoid
// names used by the OS, so don't prefix yours with "__".
let info = d["__TEXT"]!["myinfo"]!

let datafile = FileHandle(forReadingAtPath: filePath)!
try? datafile.seek(toOffset: UInt64(info.offset))
let data = try? datafile.read(upToCount: info.size)

let s = String(data: data!, encoding: .utf8)!

print("This is the time when the code was built:")
print(s)
