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

func execute() {
    print("install begining at path: ", FileManager.default.currentDirectoryPath)
    
    let process = Process.init()
    process.qualityOfService = .userInitiated
    if ProcessInfo.processInfo.arguments.contains(where: {$0 == "--verbose"}) {
        process.arguments = ["-c", "swift build -c release --product buildcannon --verbose"]
    } else {
        process.arguments = ["-c", "swift build -c release --product buildcannon"]
    }
    if #available(OSX 10.13, *) {
        process.executableURL = URL.init(fileURLWithPath: "file:///bin/sh")
    } else {
        process.launchPath = "/bin/sh"
    }
    process.launch()
    process.waitUntilExit()
    
    copyBinary()
    
    if process.terminationStatus == 0 {
        print("install complete")
        print("execute buildcannon --help")
    } else {
        print("failed to install with exit code \(process.terminationStatus)")
        print("re-run with --verbose to see details")
    }
}

execute()
