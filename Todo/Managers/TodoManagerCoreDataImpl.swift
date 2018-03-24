//  Copyright (c) 2018 Lyle Resnick. All rights reserved.

import Foundation
import CoreData

class TodoManagerCoreDataImpl: TodoManager {
    
    let manager: CoreDataManager
    init(manager: CoreDataManager) {
        self.manager = manager
    }
    
    private let fetchRequestAll =  NSFetchRequest<TodoCoreData>(entityName: "Todo")
    
    private func fetchRequest(id: String) -> NSFetchRequest<TodoCoreData> {
        
        let fetchRequest = NSFetchRequest<TodoCoreData>(entityName: "Todo")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        return fetchRequest
    }

    func all(completion: (TodoListManagerResponse) -> ()) {
        
        do {
            let todos = try manager.persistentContainer.viewContext.fetch(fetchRequestAll)
            let todoData = todos.map { Todo(todoCoreData: $0) }
            completion(.success(entity: todoData))

        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func fetch(id: String, completion: (TodoItemManagerResponse) -> ()) {

        do {
            
            let todos = try manager.persistentContainer.viewContext.fetch(fetchRequest(id: id))
            let todoData = todos.map { Todo(todoCoreData: $0) }
            completion(.success(entity: todoData.first!))
        }
        catch {
            
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func completed(id: String, completed: Bool, completion: (TodoItemManagerResponse) -> ()) {
        
        do {
            
            let todoCoreDataList = try manager.persistentContainer.viewContext.fetch(fetchRequest(id: id))
            let todoCoreData = todoCoreDataList.first!
            
            todoCoreData.completed = completed

            try manager.save()
            completion(.success(entity: Todo(todoCoreData: todoCoreData) ) )
        }
        catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func create(
            values: TodoValues,
            completion: (TodoItemManagerResponse) -> ()) {
        
        let todoCoreData = NSEntityDescription.insertNewObject(forEntityName: "Todo", into: manager.persistentContainer.viewContext) as! TodoCoreData
        
        let id = UUID()

        todoCoreData.id = id
        assignValues(todoCoreData: todoCoreData, todoValues: values)
        do {
            try manager.save()
            completion(.success(entity: Todo(id: id.uuidString, values: values) ) )
        }
        catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    private func assignValues(todoCoreData: TodoCoreData, todoValues: TodoValues) {
        
        todoCoreData.title = todoValues.title
        todoCoreData.note = todoValues.note
        todoCoreData.priority = (todoValues.priority != nil) ? todoValues.priority!.rawValue : nil
        todoCoreData.completeBy = todoValues.completeBy
        todoCoreData.completed = todoValues.completed
    }

    func update(
            id: String,
            values: TodoValues,
            completion: (TodoItemManagerResponse) -> ()) {

        do {
            
            let todoCoreDataList = try manager.persistentContainer.viewContext.fetch(fetchRequest(id: id))
            let todoCoreData = todoCoreDataList.first!
            
            assignValues(todoCoreData: todoCoreData, todoValues: values)
            try manager.save()
            completion(.success(entity: Todo(id: id, values: values) ) )
        }
        catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func delete(id: String, completion: (TodoItemManagerResponse) -> ()) {
        
        do {
            
            let todoCoreDataList = try manager.persistentContainer.viewContext.fetch(fetchRequest(id: id))
            let todoCoreData = todoCoreDataList.first!
            
            let todo = Todo(todoCoreData: todoCoreData)
            manager.persistentContainer.viewContext.delete(todoCoreData)
            try manager.save()
            completion(.success(entity: todo) )
        }
        catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}

