//
//  Persistence.swift
//  QBrush
//
//  Created by Trae on 2026/2/1.
//

import CoreData

/// Core Data 栈管理器
/// 负责初始化 NSPersistentContainer 并管理 Core Data 上下文
struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    /// 预览专用实例（内存存储）
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // 可以在这里添加预览用的模拟数据
        return result
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "QBrush")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // 生产环境中应该妥善处理错误，而不是 fatalError
                // 例如记录日志或向用户展示错误提示
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // 自动合并父上下文的更改，确保视图上下文保持最新
        container.viewContext.automaticallyMergesChangesFromParent = true
        // 解决合并冲突的策略：内存中的更改优先
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
