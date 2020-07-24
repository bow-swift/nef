//  Copyright © 2019 The nef Authors.

import NefCommon
import Bow
import BowEffects

public struct CoreRender<D, A> {
    let nodeProcessor: NodeProcessor<D, A>
    
    internal init(_ nodeProcessor: NodeProcessor<D, A>) {
        self.nodeProcessor = nodeProcessor
    }
    
    public func render(content: String) -> EnvIO<D, CoreRenderError, RenderingOutput<A>> {
        let content = "\(content.trimmingNewLines)\n"
        let syntaxAST = SyntaxAnalyzer.parse(content: content)
        guard syntaxAST.count > 0 else { return EnvIO.raiseError(.ast)^ }

        let filteredAST = syntaxAST.reduce()
        let ast = filteredAST.map { "\($0)" }.joined(separator: "\n")
        
        return filteredAST.traverse(nodeProcessor.render)
                          .flatMap(nodeProcessor.merge)
                          .map { output in .init(ast: ast, output: output) }^
    }
}

struct NodeProcessor<D, A> {
    let render: (Node) -> EnvIO<D, CoreRenderError, A>
    let merge: ([A]) -> EnvIO<D, CoreRenderError, NEA<A>>
}


// MARK: - dependencies <CoreRender>

public extension CoreRender where D == CoreJekyllEnvironment, A == String {
    static var jekyll: CoreRender { .init(.jekyll) }
}

public extension CoreRender where D == CoreMarkdownEnvironment, A == String {
    static var markdown: CoreRender { .init(.markdown) }
}

public extension CoreRender where D == CoreCarbonEnvironment, A == Image {
    static var carbon: CoreRender { .init(.carbon) }
}

public extension CoreRender where D == CoreCodeEnvironment, A == String {
    static var code: CoreRender { .init(.code) }
}
