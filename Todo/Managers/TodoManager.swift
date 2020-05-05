//  Copyright (c) 2018 Lyle Resnick. All rights reserved.

import Foundation

enum  TodoSemanticEvent: SemanticEvent {
    case notFound
    case noData
}

typealias TodoListManagerResponse = ManagerResponse<[Todo]>
typealias TodoItemManagerResponse = ManagerResponse<Todo>

protocol TodoManager {
    
    func all(completion: @escaping (TodoListManagerResponse) -> ())
    func completed(id: String, completed: Bool, completion: @escaping (TodoItemManagerResponse) -> ())
    
    func create(
                values: TodoValues,
                completion: @escaping (TodoItemManagerResponse) -> ())
    
    func update(id: String,
                values: TodoValues,
                completion: @escaping (TodoItemManagerResponse) -> ())
    
    func fetch(id:String, completion: @escaping (TodoItemManagerResponse) -> ())
    
    func delete(id:String, completion: @escaping (TodoItemManagerResponse) -> ())
}



