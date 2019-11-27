//  Copyright © 2019 The nef Authors.

import Foundation

enum PlaygroundBookTemplate {
    
    // MARK: - Code
    enum Code {
        static let header = """
                            //#-hidden-code
                            import UIKit
                            import PlaygroundSupport

                            let liveView = UIView()
                            
                            PlaygroundPage.current.liveView = liveView
                            PlaygroundPage.current.needsIndefiniteExecution = true

                            enum PlaygroundColor {
                                static let nef = UIColor(red: 140/255.0, green: 68/255.0, blue: 1, alpha: 1)
                                static let bow = UIColor(red: 213/255.0, green: 64/255.0, blue: 72/255.0, alpha: 1)
                                static let white = UIColor.white
                                static let black = UIColor.black
                                static let yellow = UIColor(red: 1, green: 237/255.0, blue: 117/255.0, alpha: 1)
                                static let green = UIColor(red: 110/255.0, green: 240/255.0, blue: 167/255.0, alpha: 1)
                                static let blue = UIColor(red: 66/255.0, green: 197/255.0, blue: 1, alpha: 1)
                                static let orange = UIColor(red: 1, green: 159/255.0, blue: 70/255.0, alpha: 1)
                            }

                            enum PlaygroundLog {
                                static var log: String {
                                    guard let assessmentStatus = PlaygroundPage.current.assessmentStatus else { return "" }

                                    switch assessmentStatus {
                                    case let .pass(message): return message ?? ""
                                    default: return ""
                                    }
                                }

                                static func print(_ message: String, clearAfter seconds: Int = 0) {
                                    let newMessage = "◦ \\(message)"
                                    let assessmentStatus = log.isEmpty ? newMessage : "\\(log)\\n\\n\\(newMessage)"
                                    PlaygroundPage.current.assessmentStatus = .pass(message: assessmentStatus)
                                    if (seconds > 0) { PlaygroundLog.clear(after: seconds) }
                                }

                                static func clear(after seconds: Int = 0) {
                                    guard seconds > 0 else {
                                        PlaygroundPage.current.assessmentStatus = nil; return
                                    }

                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds)) {
                                        PlaygroundPage.current.assessmentStatus = nil
                                    }
                                }
                            }

                            PlaygroundLog.clear()
                            //#-end-hidden-code
                            liveView.backgroundColor = PlaygroundColor.nef
                            PlaygroundLog.print("Welcome to nef Playground!")
                            """
    }
    
    // MARK: - Manifest
    enum Manifest {
        static let header = """
                            <?xml version="1.0" encoding="UTF-8"?>
                             <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                             <plist version="1.0">
                            """
        
        static func page(name: String) -> String {
            """
            \(Manifest.header)
            <dict>
                <key>Name</key>
                <string>\(name)</string>
                <key>LiveViewEdgeToEdge</key>
                <true/>
                <key>LiveViewMode</key>
                <string>VisibleByDefault</string>
            </dict>
            </plist>
            """
        }
        
        static func chapter(pageName: String) -> String {
            """
            \(Manifest.header)
            <dict>
                <key>Name</key>
                <string>\(pageName)</string>
                <key>TemplatePageFilename</key>
                <string>Template.playgroundpage</string>
                <key>InitialUserPages</key>
                <array>
                    <string>\(pageName).playgroundpage</string>
                </array>
            </dict>
            </plist>
            """
        }
        
        static func general(chapterName: String, imageName: String) -> String {
            """
            \(Manifest.header)
            <dict>
                <key>Chapters</key>
                <array>
                    <string>\(chapterName).playgroundchapter</string>
                </array>
                <key>ContentIdentifier</key>
                <string>com.apple.playgrounds.blank</string>
                <key>ContentVersion</key>
                <string>1.0</string>
                <key>DeploymentTarget</key>
                <string>ios-current</string>
                <key>DevelopmentRegion</key>
                <string>en</string>
                <key>ImageReference</key>
                <string>\(imageName)</string>
                <key>SwiftVersion</key>
                <string>5.1</string>
                <key>Version</key>
                <string>7.0</string>
                <key>UserAutoImportedAuxiliaryModules</key>
                <array/>
                <key>UserModuleMode</key>
                <string>Full</string>
            </dict>
            </plist>
            """
        }
    }
}
