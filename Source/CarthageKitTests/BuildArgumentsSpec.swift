import Quick
import Nimble
import CarthageKit

class BuildArgumentsSpec: QuickSpec {
	override func spec() {
		describe("arguments") {
			func itCreatesBuildArguments(message: String, arguments: [String], configure: inout BuildArguments -> Void) {
				let workspace = ProjectLocator.Workspace(NSURL(string: "file:///Foo/Bar/workspace.xcworkspace")!)
				let project = ProjectLocator.ProjectFile(NSURL(string: "file:///Foo/Bar/project.xcodeproj")!)

				let codeSignArguments = [
					"CODE_SIGNING_REQUIRED=NO",
					"CODE_SIGN_IDENTITY=",
					"CARTHAGE=YES"
				]

				context("when configured with a workspace") {
					it(message) {
						var subject = BuildArguments(project: workspace)
						configure(&subject)

						expect(subject.arguments) == [
							"xcodebuild",
							"-workspace",
							"/Foo/Bar/workspace.xcworkspace",
						] + arguments + codeSignArguments
					}
				}

				context("when configured with a project") {
					it(message) {
						var subject = BuildArguments(project: project)
						configure(&subject)

						expect(subject.arguments) == [
							"xcodebuild",
							"-project",
							"/Foo/Bar/project.xcodeproj",
						] + arguments + codeSignArguments
					}
				}
			}

			itCreatesBuildArguments("has a default set of arguments", arguments: []) { _ in }

			itCreatesBuildArguments("includes the scheme if one is given", arguments: ["-scheme", "exampleScheme"]) { (inout subject: BuildArguments) in
				subject.scheme = "exampleScheme"
			}

			itCreatesBuildArguments("includes the configuration if one is given", arguments: ["-configuration", "exampleConfiguration"]) { (inout subject: BuildArguments) in
				subject.configuration = "exampleConfiguration"
			}
			
			itCreatesBuildArguments("includes the derived data path", arguments: ["-derivedDataPath", "/path/to/derivedDataPath"]) { (inout subject: BuildArguments) in
				subject.derivedDataPath = "/path/to/derivedDataPath"
			}
			
			itCreatesBuildArguments("includes empty derived data path", arguments: []) { (inout subject: BuildArguments) in
				subject.derivedDataPath = ""
			}
			
			itCreatesBuildArguments("includes the the toolchain", arguments: ["-toolchain", "org.swift.3020160509a"]) { (inout subject: BuildArguments) in
				subject.toolchain = "org.swift.3020160509a"
			}

			describe("specifying the sdk") {
				for sdk in SDK.allSDKs {
					itCreatesBuildArguments("includes \(sdk) in the argument if specified", arguments: ["SDKROOT=\(sdk.rawValue)"]) { (inout subject: BuildArguments) in
						subject.sdk = sdk
					}
				}
			}

			itCreatesBuildArguments("includes the destination if given", arguments: ["-destination", "exampleDestination"]) { (inout subject: BuildArguments) in
				subject.destination = "exampleDestination"
			}

			describe("specifying onlyActiveArchitecture") {
				itCreatesBuildArguments("includes ONLY_ACTIVE_ARCH=YES if it's set to true", arguments: ["ONLY_ACTIVE_ARCH=YES"]) { (inout subject: BuildArguments) in
					subject.onlyActiveArchitecture = true
				}

				itCreatesBuildArguments("includes ONLY_ACTIVE_ARCH=NO if it's set to false", arguments: ["ONLY_ACTIVE_ARCH=NO"]) { (inout subject: BuildArguments) in
					subject.onlyActiveArchitecture = false
				}
			}

			describe("specifying the bitcode generation mode") {
				itCreatesBuildArguments("includes BITCODE_GENERATION_MODE=marker if .Marker is set", arguments: ["BITCODE_GENERATION_MODE=marker"]) { (inout subject: BuildArguments) in
					subject.bitcodeGenerationMode = .Marker
				}

				itCreatesBuildArguments("includes BITCODE_GENERATION_MODE=bitcode if .Bitcode is set", arguments: ["BITCODE_GENERATION_MODE=bitcode"]) { (inout subject: BuildArguments) in
					subject.bitcodeGenerationMode = .Bitcode
				}
			}
		}
	}
}
