typealias Byte = UInt8

class Tripoli {

    // state
    var interpreting = false
    var mainStack = Stack()
    var wordList : [String:Word] = [:]
    var here : Int = 0 
    var dataSpace = [Int]()

    var inputBuffer: String = ""
    var tokens = [String]()

    // constants
    let separator : Character = " "
    let cell = 1 //UInt8.bitWidth   // This is wrong and stupid

    func push( _ value: Int ) { self.mainStack.push( value ) }
    func pop() -> Int { return self.mainStack.pop() }
    func output( _ value: Any ) { 
        print( String( describing: value), terminator: " " ) 
    }
    func error( _ msg: String ) {
        print( msg )
    }

    func interpretString( _ inputString: String ) {

        let newTokens = inputString.split( separator: separator ).map{ String( $0 ) }
        self.tokens.insert( contentsOf: newTokens, at: 0 )
        while tokens.count > 0 {
            let token = self.parseName()

            if let number = Int( token ) {
                mainStack.push( number )
            } else {
                // TODO: this doesn't handle redefines
                guard let word = wordList[String(token)] else { 
                    self.error( "Undefined word \(token)" )
                    continue 
                }
                word.int()
            }
        }
    }

    func compile() -> String {
        return self.parseName()
    }



    func startInterpreter() {
        self.interpreting = true
        print( "Interpreting..." )
        while self.interpreting {
            let input = readLine()
            guard let inputString = input else { return }
            self.interpretString( inputString )
            print("ok" )
        }
    }

    func initDataSpace() {
        for x in 0...1024 {
            dataSpace.insert( 0, at: x )
        }
    }

    func parseName() -> String {
        let name = self.tokens.removeFirst()
        guard !name.isEmpty else { self.error( "Zero length name"); fatalError() }
        return name

    }

}

extension Byte {

    // this, but it should do something
    func hex() -> String {
        return String( self )
    }

}

// word list
extension Tripoli {

    func buildWordList() {
        wordList["."] = Word({ self.output( self.pop() ) })
        wordList["."] = Word( { self.output( self.pop()) } )
        wordList["+"] = Word({ 
            let result = self.pop() + self.pop()
            self.push( result ) 
        })
        wordList["bye"] = Word({ self.interpreting = false })
        wordList["drop"] = Word({ _ = self.pop() })
        wordList["swap"] = Word({ 
            let tmp = self.pop()
            let tmp2 = self.pop()
            self.push( tmp )
            self.push( tmp2 )
        })
        wordList["over"] = Word({
            let tmp = self.pop()
            let tmp2 = self.pop()
            self.push( tmp2 )
            self.push( tmp )
            self.push( tmp2 )
        })
        wordList["dup"] = Word({
            let tmp = self.pop()
            self.push( tmp )
            self.push( tmp )
        })
        wordList["2dup"] = Word({
            self.interpretString( "over over")
        })
        wordList[".s"] = Word({
            self.output( "<\(self.mainStack.array.count)>")
            _ = self.mainStack.array.reversed().map {
                self.output( $0 )
            }
        })
        wordList["depth"] = Word({ self.push( self.mainStack.array.count ) })
        wordList["here"] = Word({ self.push( Int( self.here ) ) })

        // I don't really know what I'm doing
        // but I think this is going to be something like storing
        // the name in the data-space
        // adding a field that has code to push the value of 
        wordList["create"] = Word({
            let name = self.parseName()
            let value = self.here
            self.here = self.here + self.cell
            self.wordList[name] = Word({
                self.interpretString( String( value)  )
            })
        })
        wordList[","] = Word({ 
            let tmp = self.pop()
            self.dataSpace[self.here] = tmp
            self.here = self.here + self.cell
        })
        wordList["!"] = Word({
            let address = self.pop()
            let value = self.pop()
            self.dataSpace[address] = value
        })
        wordList["@"] = Word({
            let tmp = self.pop()
            let result = self.dataSpace[tmp]
            self.push( result )
        })
        wordList[":"] = Word( {
            let name = self.parseName()
            self.here = self.here + self.cell
            var compiledString = ""
            while true {
                let token = self.compile()
                if token == ";" { break }
                compiledString.append( token )
                compiledString.append( " " )
            }
            self.wordList[name] = Word( {
                self.interpretString( compiledString )
            })
        })
        wordList[";"] = Word( {
            self.interpreting = true
        })

    }
}

extension Array where Element == Byte {

    func doit() { print( "Hello, World!" ) }

    func append( _ integer: Int, at: Int ) {

    }

}
