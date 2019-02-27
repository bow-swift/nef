import Foundation

protocol Render {
    func render(content: String) -> String?
}

protocol Jekyll {
    func jekyll(permalink: String) -> String
}

// Dependencies
extension Node: Jekyll {}
