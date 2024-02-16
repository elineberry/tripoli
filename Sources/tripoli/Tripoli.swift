typealias Byte = UInt8

class Tripoli {

    // state
    var interpreting = false
    var mainStack = Stack()
    var wordList : [String:() -> ()] = [:]
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
                word()
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
        wordList["."] = { self.output( self.pop() ) }
        wordList["+"] = { 
            let result = self.pop() + self.pop()
            self.push( result ) 
        }
        wordList["bye"] = { self.interpreting = false }
        wordList["drop"] = { _ = self.pop() }
        wordList["swap"] = { 
            let tmp = self.pop()
            let tmp2 = self.pop()
            self.push( tmp )
            self.push( tmp2 )
        }
        wordList["over"] = {
            let tmp = self.pop()
            let tmp2 = self.pop()
            self.push( tmp2 )
            self.push( tmp )
            self.push( tmp2 )
        }
        wordList["dup"] = {
            let tmp = self.pop()
            self.push( tmp )
            self.push( tmp )
        }
        wordList["2dup"] = {
            self.interpretString( "over over")
        }
        wordList[".s"] = {
            self.output( "<\(self.mainStack.array.count)>")
            _ = self.mainStack.array.reversed().map {
                self.output( $0 )
            }
        }
        wordList["depth"] = { self.push( self.mainStack.array.count ) }
        wordList["here"] = { self.push( Int( self.here ) ) }

        // I don't really know what I'm doing
        // but I think this is going to be something like storing
        // the name in the data-space
        // adding a field that has code to push the value of 
        wordList["create"] = {
            let name = self.parseName()
            let value = self.here
            self.here = self.here + self.cell
            self.wordList[name] = {
                self.interpretString( String( value)  )
            }
        }
        wordList[","] = { 
            let tmp = self.pop()
            self.dataSpace[self.here] = tmp
            self.here = self.here + self.cell
        }
        wordList["!"] = {
            let address = self.pop()
            let value = self.pop()
            self.dataSpace[address] = value
        }
        wordList["@"] = {
            let tmp = self.pop()
            let result = self.dataSpace[tmp]
            self.push( result )
        }
        wordList[":"] = {
            let name = self.parseName()
            self.here = self.here + self.cell
            var compiledString = ""
            while true {
                var token = self.compile()
                if token == ";" { break }
                compiledString.append( token )
                compiledString.append( " " )
            }
            self.wordList[name] = {
                self.interpretString( compiledString )
            }
        }
        wordList[";"] = {
            self.interpreting = true
        }
    }
}

extension Array where Element == Byte {

    func doit() { print( "Hello, World!" ) }

    func append( _ integer: Int, at: Int ) {

    }

}

// what if I had a struct with here and length, and then I could print them out
// in a dump or create , or whatever. And I don't have to do lookups from stuff
// in a data array
// pad would be easy to implement, just store all the strings

// link field -- 2 cells
    // link field 1st cell -- addr of previous entry
    // count of chars in string terminated with hex 80
// name field -- string
// code name    -- 2 cells
    // the 
// parameter field  -- 4 cells, padded with FF
//
// ' returns code name field of a word
// ' "word" >name returns link field of a word

// so I'm thinking of a struct with a protocol for a default method
// I'm not sure how that would work
// Either way, creating a word will add it to the array
// no. that's backwards. No, that will work. The different constructor behavior
// Let's try to implement and see what happens.

// of course, I could just write it in swift and not worry about the byte
// implementation. It doesn't serve a design purpose? Does it?
// ooo, store the original code in a string so the see function always works
// but then stuff like create , would have little meaning. How would we know?
// I'm going to need a worklog

// Uh... this is just how I'm doing it for now
struct Word {
    let interpretation : () -> ()
    let compilation : () -> ()
    let runtime : () -> ()
}
