//
//  FileGenerator.swift
//  Shari
//
//  Created by Horus on 5/13/24.
//

import Foundation

enum SupportedFileExtension: String {
    case markdown = ".md"
    case csv = ".csv"
}

protocol FileGenerator {
    func createFile(contents: String, fileName: String, fileExtension: SupportedFileExtension)
    func removeFile(fileName: String, fileExtension: SupportedFileExtension)
}

final class DefaultFileGenerator: FileGenerator {

    func createFile(contents: String, fileName: String, fileExtension: SupportedFileExtension) {
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileUrl = documentsUrl.appendingPathComponent(fileName + fileExtension.rawValue)
            do {
                try contents.write(to: fileUrl, atomically: true, encoding: .utf8)
            } catch {
                print("File creation failed.")
            }
        } else {
            
        }
    }
    
    func removeFile(fileName: String, fileExtension: SupportedFileExtension) {
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileUrl = documentsUrl.appendingPathComponent(fileName + fileExtension.rawValue)
            do {
                try FileManager.default.removeItem(at: fileUrl)
            } catch {
                print("File creation failed.")
            }
        } else {
            
        }
    }
    
}
