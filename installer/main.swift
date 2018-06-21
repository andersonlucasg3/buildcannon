import Foundation

func copyBinary() {
    let path = URL.init(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let binary = path.appendingPathComponent(".build/release/buildcannon")
    if FileManager.default.fileExists(atPath: binary.path) {
        try! FileManager.default.copyItem(atPath: binary.path, toPath: "/usr/local/bin/buildcannon")
    } else {
        print("couldn't copy built binary to /usr/local/bin")
        print("re-run with --verbose to see details")
    }
}

@discardableResult
func executeProcess(_ command: String, _ verbose: Bool) -> Int32 {
    let process = Process.init()
    process.qualityOfService = .userInitiated
    process.arguments = ["-c", "\(command)\(verbose ? " --verbose" : "")"]
    if #available(OSX 10.13, *) {
        process.executableURL = URL.init(fileURLWithPath: "file:///bin/sh")
    } else {
        process.launchPath = "/bin/sh"
    }
    process.launch()
    process.waitUntilExit()
    
    return process.terminationStatus
}

func execute() {
    print("install starting at path: \(FileManager.default.currentDirectoryPath)")
    
    let verbose = ProcessInfo.processInfo.arguments.contains(where: {$0 == "--verbose"})
    
    executeProcess("git clone https://github.com/andersonlucasg3/buildcannon", verbose)
    executeProcess("cd buildcannon", verbose)
    
    print("build starting at path: \(FileManager.default.currentDirectoryPath)")
    
    let terminationStatus = executeProcess("swift build -c release --product buildcannon", verbose)
    executeProcess("cd ..", verbose)
    executeProcess("rm -rf buildcannon", verbose)
    
    copyBinary()
    
    if terminationStatus == 0 {
        print("install complete")
        print("execute buildcannon --help")
    } else {
        print("failed to install with exit code \(terminationStatus)")
        print("re-run with --verbose to see details")
    }
}

execute()
