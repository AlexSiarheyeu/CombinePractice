import Foundation
import Combine
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

enum CustomError: Int, Error, Codable {
    case outOfGas
}

var recording = Record<Int, CustomError>.Recording()

let pub = [1,2,3].publisher
    .setFailureType(to: CustomError.self)
    .sink(receiveCompletion: { completion in
        recording.receive(completion: completion)
        
    }, receiveValue: { value in
        recording.receive(value)
        
        
    })

let recPub = Record(recording: recording)

recPub.sink(receiveCompletion: {print($0)}, receiveValue: {print($0)})


let encoder = JSONEncoder()
let data = try! encoder.encode(recPub)

print (String(data: data, encoding: .utf8))
