//
// Project «Autograph»
// Created by Jeorge Taflanidi
//


import Foundation


/**
 Utility responsible for finding *.swift files in input folders and subfolders.
 */
open class FileFinder {
    
    /**
     Find files in folders and their subfolders.
     */
    open func findFiles(inFolders folders: [String], parameters: ExecutionParameters) throws -> [URL] {
        return
            try folders
                .reduce([]) { (files: [URL], folder: String) -> [URL] in
                    return try files + self.findFiles(inFolder: folder, parameters: parameters)
                }
    }
    
    /**
     Find files in folder and its subfolders.
     */
    open func findFiles(inFolder folder: String, parameters: ExecutionParameters) throws -> [URL] {
        return
            try fileListInFolder(folder: folder, verbose: parameters.verbose)
                .filter { (filePath: String) -> Bool in
                    return filePath.lowercased().hasSuffix(".swift")
                }
                .map { URL(fileURLWithPath: $0) }
    }
    
}

private extension FileFinder {
    
    func fileListInFolder(folder: String, verbose: Bool) throws -> [String] {
        let folderPath: String = self.makeAbsolutePath(path: folder, verbose: verbose)
        
        if verbose {
            Log.v("Scanning folder: \(folderPath)")
        }
        
        let filesAtFolder: [String] = try self.filesAtFolder(folder: folderPath)
        if verbose && !filesAtFolder.isEmpty {
            Log.v("Found files:\n\(filesAtFolder.joined(separator: ",\n"))")
        }
        
        let foldersAtFolder: [String] = try self.foldersAtFolder(folder: folderPath)
        if verbose && !foldersAtFolder.isEmpty {
            Log.v("Found subfolders:\n\(foldersAtFolder.joined(separator: ",\n"))")
        }
        
        let filesInSubfolders: [String] = try foldersAtFolder.reduce([]) { (items: [String], folder: String) -> [String] in
            return try items + self.fileListInFolder(folder: folder, verbose: verbose)
        }
        
        return filesAtFolder + filesInSubfolders
    }
    
    func makeAbsolutePath(path: String, verbose: Bool) -> String {
        let workingDirectory: String = FileManager.default.currentDirectoryPath
        
        if path.isEmpty {
            return workingDirectory
        } else {
            if path.hasPrefix(".") {
                return workingDirectory + "/" + path
            } else {
                return path
            }
        }
    }
    
    func filesAtFolder(folder: String) throws -> [String] {
        return try self.itemsAtFolder(folderPath: folder, directories: false)
    }
    
    func foldersAtFolder(folder: String) throws -> [String] {
        return try self.itemsAtFolder(folderPath: folder, directories: true)
    }
    
    func itemsAtFolder(folderPath: String, directories: Bool) throws -> [String] {
        let fileManager: FileManager = FileManager()
        let folderContents: [String] = try fileManager.contentsOfDirectory(atPath: folderPath)
        
        return folderContents.flatMap { (path: String) -> String? in
            var isFolder: ObjCBool = ObjCBool(false)
            let fullPath: String   = folderPath + "/" + path
            
            fileManager.fileExists(atPath: fullPath, isDirectory: &isFolder)
            if directories == isFolder.boolValue {
                return fullPath
            }
            
            return nil
        }
    }
}
