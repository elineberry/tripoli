struct Word {
    typealias exec = () -> ()
    let int : exec
    let com : exec
    let run : exec

    init( int: @escaping exec, com: @escaping exec, run: @escaping exec ) {
        self.int = int
        self.com = com
        self.run = run
    }

    init( _ int: @escaping exec ) {
        self.int = int
        self.com = int
        self.run = int
    }
}
