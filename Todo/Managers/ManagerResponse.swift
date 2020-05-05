
protocol SemanticEvent: Error {
    
}

enum DataSources {
    case test
    case coreData
    case networked
}

enum ManagerResponse<Entity, Event: SemanticEvent> {
    case success(entity: Entity)
    case failure(source: DataSources, code: Int, description: String)
    case semantic(event: Event)
}
