//  Copyright (c) 2018 Lyle Resnick. All rights reserved.

import Foundation

struct TodoListViewModel {
    
    let id: String
    let title: String
    let date: String
    let priority: String
    let done: Bool
    
    init(model: TodoListPresentationModel) {
        self.id = model.id
        self.title = model.title
        self.date = (model.date != nil) ? TodoListViewModel.outboundDateFormatter.string(from: model.date!) : ""
        self.priority = TodoListViewModel.bangString(priority: model.priority)
        self.done = model.done
    }
    
    private static let outboundDateFormatter = DateFormatter.dateFormatter( format: "MMM' 'dd', 'yyyy" )
    
    private static func bangString(priority: Todo.Priority? ) -> String {
    
        let bangCount = priority != nil ? priority!.bangs : 0
        return (0..<bangCount).reduce(" ") { result, index in "!\(result)" }
    }

}

