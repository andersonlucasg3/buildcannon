//
//  TestsExecutor.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 17/05/19.
//  Copyright © 2019 InsaniTech. All rights reserved.
//

import Foundation

//xcodebuild -workspace <your_xcworkspace> -scheme <your_scheme> -sdk iphonesimulator -destination ‘platform=iOS Simulator,name=<your_simulator>,OS=10.2’ build-for-testing
//xcodebuild -workspace <your_xcworkspace> -scheme <your_scheme> -sdk appletvsimulator -destination ‘platform=tvOS Simulator,name=<your_simulator>,OS=10.2’ build-for-testing

class TestsExecutor: ExecutorProtocol {
    fileprivate let separator = " "
    fileprivate var commandExecutor: CommandExecutor!
    
    weak var delegate: ExecutorCompletionProtocol?
    
    required init() {
        
    }
    
    convenience init(project: DoubleDashComplexParameter?, target: DoubleDashComplexParameter?, scheme: DoubleDashComplexParameter, sdk: DoubleDashComplexParameter?,
                     platform: DoubleDashComplexParameter, device: DoubleDashComplexParameter, osVersion: DoubleDashComplexParameter) {
        self.init()
        
        let logFile = TestTool.Values.testsLogPath(platform: platform.composition, osVersion: osVersion.composition)
        self.commandExecutor = CommandExecutor.init(path: TestTool.toolPath, application: TestTool.toolName, logFilePath: logFile)
        if let project = project {
            self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: self.projectParam(for: project), composition: project.composition, separator: self.separator))
        }
        if let target = target {
            self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: TestTool.Parameters.targetParam, composition: target.composition, separator: self.separator))
        }
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: TestTool.Parameters.schemeParam, composition: scheme.composition, separator: self.separator))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: TestTool.Parameters.sdkParam, composition: sdk?.composition ?? TestTool.Values.sdkConfig, separator: self.separator))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: TestTool.Parameters.destinationParam, composition: self.destinationValue(with: platform, device: device, and: osVersion), separator: self.separator))
        self.commandExecutor.add(parameter: NoDashParameter.init(parameter: TestTool.Parameters.cleanParam))
        self.commandExecutor.add(parameter: NoDashParameter.init(parameter: TestTool.Parameters.testParam))
        
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: TestTool.Parameters.useModernBuildSystem,
                                                                            composition: self.isUseLegacyBuildSystemParameterPresent() ? "NO" : "YES",
                                                                            separator: "=")) // separator must be `=`
        
        let xcpretty = !Application.isVerbose && Application.isXcprettyInstalled
        if xcpretty {
            self.commandExecutor.add(parameter: NoDashParameter.init(parameter: "| xcpretty && exit ${PIPESTATUS[0]}"))
        }
    }
    
    fileprivate func isUseLegacyBuildSystemParameterPresent() -> Bool {
        return Application.processParameters.contains(where: {$0.parameter == InputParameter.Project.useLegacyBuildSystem.name})
    }
    
    fileprivate func projectParam(for parameter: DoubleDashComplexParameter) -> String {
        return parameter.buildParameter().contains(".xcworkspace") ?
            TestTool.Parameters.workspaceParam : TestTool.Parameters.projectParam
    }
    
    fileprivate func destinationValue(with platform: DoubleDashComplexParameter, device: DoubleDashComplexParameter, and os: DoubleDashComplexParameter) -> String {
        return "\"platform=\(platform.composition) Simulator,name=\(device.composition),OS=\(os.composition)\""
    }
    
    fileprivate func dispatchFinish(_ returnCode: Int) {
        Application.execute { [weak self] in
            guard let self = self else { return }
            if returnCode == 0 {
                self.delegate?.executorDidFinishWithSuccess(self)
            } else {
                self.delegate?.executor(self, didFailWithErrorCode: returnCode)
            }
        }
    }
    
    func execute() {
        self.commandExecutor.execute(tag: "TestsExecutor") { [weak self] (returnCode, _) in
            self?.dispatchFinish(returnCode)
        }
    }
    
    func cancel() {
        self.commandExecutor.stop()
    }
}
