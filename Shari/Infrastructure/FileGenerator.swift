//
//  FileGenerator.swift
//  Shari
//
//  Created by Horus on 5/13/24.
//

import Foundation

protocol FileGenerator {
    func createFile(contents: String, url: URL)
    func removeFile(url: URL)
}

final class DefaultFileGenerator: FileGenerator {

    func createFile(contents: String, url: URL) {
        do {
            try contents.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("File creation failed.")
        }
    }
    
    func removeFile(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("File creation failed.")
        }
    }
    
}
