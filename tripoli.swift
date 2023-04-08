@main
class Tripoli {

    static func main() throws {
        print( "Tripoli" )
        let tripoli = Tripoli()
        tripoli.initDataSpace()
        tripoli.buildWordList()
        tripoli.startInterpreter()
    }

    // state
    var interpreting = false
    var mainStack = Stack()
    var wordList : [String:() -> ()] = [:]
    var here : Int = 0
    var dataSpace = [Int]()

    // constants
    let separator : Character = " "
    func push( _ value: Int ) { self.mainStack.push( value ) }
    func pop() -> Int { return self.mainStack.pop() }
    func output( _ value: Any ) { 
        print( String( describing: value), terminator: " " ) 
    }
    func error( _ msg: String ) {
        print( msg )
    }

    func startInterpreter() {
        self.interpreting = true
        print( "Interpreting..." )
        while self.interpreting {
            let input = readLine()
            guard let inputString = input else { return }

            let tokens = inputString.split( separator: separator )
            for x in tokens {
                if let number = Int( x ) {
                    mainStack.push( number )
                } else {
                    guard let word = wordList[String(x)] else { 
                        self.error( "Undefined word" )
                        continue 
                    }
                    word()
                }

            }
            print("ok" )
        }
    }

    func initDataSpace() {
        for x in 0...1024 {
            dataSpace.insert( 0, at: x )
        }
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

        }
        wordList[","] = { 
            let tmp = self.pop()
            self.dataSpace[self.here] = tmp
            self.here = self.here + 1
        }
        wordList["@"] = {
            let tmp = self.pop()
            let result = self.dataSpace[tmp]
            self.push( result )
        }
    }
}

class Stack {

    var array = [Int]()

    func pop() -> Int {
        return array.removeFirst()
    }

    func push( _ value: Int ) {
        array.insert( value , at: 0 )
    }
}
