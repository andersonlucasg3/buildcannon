import Foundation

@discardableResult
func executeProcess(_ command: String, _ verbose: Bool, _ currentPath: String? = nil) -> Int32 {
    let process = Process.init()
    process.qualityOfService = .userInitiated
    process.arguments = ["-c", "\(command)\(verbose ? " --verbose" : "")"]
    if #available(OSX 10.13, *) {
        process.executableURL = URL.init(fileURLWithPath: "file:///bin/sh")
    } else {
        process.launchPath = "/bin/sh"
    }
    if let currentPath = currentPath {
        process.currentDirectoryPath = currentPath
    }
    process.launch()
    process.waitUntilExit()
    
    return process.terminationStatus
}

func execute() {
    let path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let cannonPath = path.appendingPathComponent("buildcannon")
    print("install starting at path: \(path.path)")
    
    let verbose = ProcessInfo.processInfo.arguments.contains(where: {$0 == "--verbose"})
    
    executeProcess("git clone -b master https://github.com/andersonlucasg3/buildcannon", verbose)
    
    print("build starting at path: \(cannonPath.path)")
    
    let terminationStatus = executeProcess("swift build -Xswiftc -static-stdlib -c release --product buildcannon", verbose, cannonPath.path)
    
    if terminationStatus == 0 {
        print("install complete")
        print("execute buildcannon --help")
    } else {
        print("failed to install with exit code \(terminationStatus)")
        print("re-run with --verbose to see details")
    }
}

execute()
