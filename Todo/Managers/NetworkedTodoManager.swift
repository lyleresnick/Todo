//  Copyright © 2020 Lyle Resnick. All rights reserved.

import Foundation

class NetworkedTodoManager: TodoManager {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    private let defaultSession = URLSession(configuration: .default)
    private let baseURL = URL(string: "https://todobackend-lyle.herokuapp.com/api")!
    
    private let formatter = DateFormatter.dateFormatter( format:"yyyy'-'MM'-'dd'T23:59:59Z'")
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
    private lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .formatted(formatter)
        return encoder
    }()

    func all(completion: @escaping (TodoListManagerResponse) -> ()) {
        let url = baseURL.appendingPathComponent("todo")

        let dataTask = defaultSession.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(source: .networked, code: 0, description: error.localizedDescription))
                return
            }
            if let data = data, let response = response as? HTTPURLResponse {
                if  response.statusCode == 200 {
                    do {
                        let networkedTodoList = try self.decoder.decode([NetworkedTodo].self, from: data)
                        let todoList = networkedTodoList.compactMap {
                            return Todo(networkedTodo: $0)
                        }
                        completion(.success(entity: todoList))
                    }
                    catch {
                        completion(.failure(source: .networked, code: 0, description: "JSON: error decoding '[NetworkedTodo]': \(error.localizedDescription)"))
                    }
                }
                else {
                    completion(.failure(source: .networked, code: response.statusCode, description: "Networking Error"))
                }
            }
        }
        dataTask.resume()
    }
    
    func fetch(id:String, completion: @escaping (TodoItemManagerResponse) -> ()) {
        
        doDataTask(id: id, method: .get, completion: completion, errorResolver: { response in
            if response.statusCode == 404 {
                completion(.semantic(event: .notFound))
                return true
            }
            return false
        })
    }
    
    private func doDataTask(id:String,
                            method: HTTPMethod,
                            completion: @escaping (TodoItemManagerResponse) -> (),
                            errorResolver: ((HTTPURLResponse) -> Bool)? = nil) {

        let url = baseURL.appendingPathComponent("todo/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        let dataTask = defaultSession.dataTask(with: request ) { data, response, error in
            self.processResponse(data: data, response: response, error: error, completion: completion, errorResolver: errorResolver)
        }
        dataTask.resume()
    }
    
    private func processResponse(data: Data?,
                                 response: URLResponse?,
                                 error: Error?,
                                 completion: @escaping (TodoManagerResponse) -> (),
                                 errorResolver: ((HTTPURLResponse) -> Bool)?) {
        if let error = error {
            return completion(.failure(source: .networked, code: 0, description: error.localizedDescription))
        }
        if let data = data, let response = response as? HTTPURLResponse {
            if  response.statusCode == 200 {
                do {
                    let networkedTodo = try self.decoder.decode(NetworkedTodo.self, from: data)
                    if let todo = Todo(networkedTodo: networkedTodo) {
                        return completion(.success(entity: todo))
                    }
                }
                catch {
                    return completion(.failure(source: .networked, code: 0, description: "JSON: error decoding 'NetworkedTodo': \(error.localizedDescription)"))
                }
            }
            else {
                guard
                    let errorResolver = errorResolver, errorResolver(response)
                else {
                    return completion(.failure(source: .networked, code: response.statusCode, description: "Networking Error"))
                }
                return
            }
        }
    }
    
    func completed(id:String, completed: Bool, completion: @escaping (TodoItemManagerResponse) -> ()) {
        
        func completionOfGet(_ todoResponse: TodoItemManagerResponse) {
            switch todoResponse {
            case let .success(todo):
                let todoValues = TodoValues(title: todo.title, note: todo.note, completeBy: todo.completeBy, priority: todo.priority, completed: completed)
                doUpload(values: todoValues, resource: "todo/\(id)", method: .put, completion: completion)
            default:
                completion(todoResponse)
            }
        }
        
        doDataTask(id: id, method: .get, completion: completionOfGet, errorResolver: { response in
            if response.statusCode == 404 {
                completion(.semantic(event: .notFound))
                return true
            }
            return false
        })
    }
    
    func create(
            values: TodoValues,
            completion: @escaping (TodoItemManagerResponse) -> ()) {
        
        doUpload(values: values, resource: "todo", method: .post, completion: completion)
    }
    
    private func doUpload(values: TodoValues,
                          resource: String,
                          method: HTTPMethod,
                          completion: @escaping (TodoItemManagerResponse) -> (),
                          errorResolver: ((HTTPURLResponse) -> Bool)? = nil) {
        
        let url = baseURL.appendingPathComponent(resource)
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue

        let jsonData: Data
        do {
            jsonData = try encoder.encode(NetworkedTodo(todoValues: values))
        }
        catch {
            return completion(.failure(source: .networked, code: 0, description: "JSON: error encoding 'NetworkedTodo': \(error.localizedDescription)"))
        }
        let uploadTask = defaultSession.uploadTask(with: request, from: jsonData) { data, response, error in
            self.processResponse(data: data, response: response, error: error, completion: completion, errorResolver: errorResolver)
        }
        uploadTask.resume()
    }

    func update(
            id: String,
            values: TodoValues,
            completion: @escaping (TodoItemManagerResponse) -> ()) {
        
        doUpload(values: values, resource: "todo/\(id)", method: .put, completion: completion, errorResolver: { response in
            guard response.statusCode == 404 else { return false }
            completion(.semantic(event: .notFound))
            return true
        } )
    }
    
    func delete(id: String, completion: @escaping (TodoItemManagerResponse) -> ()) {
                    
        doDataTask(id: id, method: .delete, completion: completion, errorResolver: { response in
            switch response.statusCode {
            case 404:
                completion(.semantic(event: .notFound))
                return true
            case 204:
                completion(.semantic(event: .noData))
                return true
            default:
                return false
            }
        })
    }
}
