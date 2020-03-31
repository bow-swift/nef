import BowEffects

public extension IO {
    func foldMTap<B>(_ f: @escaping (E) -> IO<E, B>,
                     _ g: @escaping (A) -> IO<E, B>) -> IO<E, A> {
        handleErrorWith { e in
            f(e).followedBy(.raiseError(e))
        }.flatTap(g)^
    }
}
