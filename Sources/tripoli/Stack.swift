
class Stack {

    var array = [Int]()

    func pop() -> Int {
        return array.removeFirst()
    }

    func push( _ value: Int ) {
        array.insert( value , at: 0 )
    }
}
