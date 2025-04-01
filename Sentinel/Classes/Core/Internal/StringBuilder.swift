//
//  StringBuilder.swift
//  Sentinel
//
//  Created by Zvonimir Medak on 10.03.2025..
//

extension String {

    init(@StringBuilder builder: () -> String) {
        self.init(builder())
    }

}

@resultBuilder
enum StringBuilder {

    static func buildBlock(_ components: CustomStringConvertible...) -> String {
        components.map { $0.description }.joined()
    }

    static func buildOptional(_ component: String?) -> String {
        component ?? .empty
    }

    static func buildEither(first component: String) -> String {
        component
    }

    static func buildEither(second component: String) -> String {
        component
    }

    static func buildArray(_ components: [String]) -> String {
        buildBlock(components)
    }

}
