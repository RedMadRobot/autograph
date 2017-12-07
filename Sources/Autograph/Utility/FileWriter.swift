//
// Project «Autograph»
// Created by Jeorge Taflanidi
//


import Foundation


/**
 Utility responsible for writing ```Implementation``` to disk.
 
 If file didn't change, writer skips it.
 */
open class FileWriter {
    
    /**
     Write implementations to disk.
     */
    open func write(implementations: [Implementation], parameters: ExecutionParameters) throws {
        try self.createRequiredFolders(forImplementations: implementations, parameters: parameters)
        
        try implementations.forEach { (implementation: Implementation) in
            try self.write(
                file: implementation.sourceCode,
                filePath: implementation.filePath,
                parameters: parameters
            )
        }
    }
    
}

private extension FileWriter {
    
    func createRequiredFolders(
        forImplementations implementations: [Implementation],
        parameters: ExecutionParameters
    ) throws {
        let fileManager: FileManager = FileManager.default
        try implementations.forEach { (implementation: Implementation) in
            let directoryUrl = URL(fileURLWithPath: implementation.filePath).deletingLastPathComponent()
            
            if parameters.verbose {
                Log.v("Creating folder: \(directoryUrl.path)")
            }
            
            try fileManager.createDirectory(
                at: directoryUrl,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }
    
    func write(file: String, filePath: String, parameters: ExecutionParameters) throws {
        if parameters.verbose {
            Log.v("Loading existing file: \(filePath)")
        }
        
        let existingFile = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        if let existingFile: String = existingFile, existingFile == file {
            if parameters.verbose {
                Log.v("File \(filePath) didn't change, skipping...")
            }
            return
        }
        
        if parameters.verbose {
            Log.v("Writing file: \(filePath)")
        }
        
        try file.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
    }
    
}
