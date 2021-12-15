//
//  CoreDataManager.swift
//  Task
//
//  Created by Amitabha Saha on 15/12/21.
//

import Foundation
import CoreData


class CoreDataManager {
    
    private var _workerContext: NSManagedObjectContext!
    private var _writerContext: NSManagedObjectContext!
    private var _container: NSPersistentContainer!
    
    static let manager: CoreDataManager = CoreDataManager()
    
    var storeName: String = "CoreDataPractiseApp"
    var storeURL : URL {
      let storePaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
      let storePath = storePaths[0] as NSString
      let fileManager = FileManager.default
      
      do {
            try fileManager.createDirectory( atPath: storePath as String, withIntermediateDirectories: true, attributes: nil)
      } catch {
            print("Error creating storePath \(storePath): \(error)")
      }
      
      let sqliteFilePath = storePath.appendingPathComponent(storeName + ".sqlite")
      return URL(fileURLWithPath: sqliteFilePath)
    }
    
    
    private init() {
        
        // Not sure should be done here or not.
        /*
        do {
           try (storeURL as NSURL).setResourceValue( URLFileProtection.complete, forKey: .fileProtectionKey)
        } catch {
            print(error.localizedDescription)
        }*/
        
        _container = NSPersistentContainer(name: "Task")
        
        let description = NSPersistentStoreDescription(url: self.storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        description.setOption(FileProtectionType.complete as NSObject?, forKey: NSPersistentStoreFileProtectionKey)
        
        _container.persistentStoreDescriptions = [description]
        
        _container.loadPersistentStores { (description, error) in
            if let _ = error {
                print("Failed To load container with datamodel")
            }
        }
        
        _workerContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        _workerContext.name = "main_worker_context"
        
        _writerContext = privateContext
        _writerContext.persistentStoreCoordinator = _container.persistentStoreCoordinator
        
        _workerContext.parent = _writerContext
        
        // Add Notification for workercontext save
        NotificationCenter.default.addObserver(self, selector: #selector(self.contextDidSaveMainQueueContext(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: _workerContext)
    }
    
    
    var container: NSPersistentContainer {
        get {
            return _container
        }
    }
    
    var privateContext: NSManagedObjectContext {
        get {
            let bgContext = _container.newBackgroundContext()
            bgContext.undoManager = nil
            bgContext.mergePolicy = NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType
            bgContext.name = "new_bg_context"
            return bgContext
        }
    }
    
    var defaultContext: NSManagedObjectContext {
        get {
            return _workerContext
        }
    }
    
    func save(image: Image, isFav: Bool) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageMO")
        fetchRequest.predicate = NSPredicate(format: "id = %@", image.id)
        do {
            if let response = try _workerContext.fetch(fetchRequest) as? [ImageMO], !response.isEmpty {
                response.first?.isFav = isFav
                saveContext()
            } else {
                if let object: ImageMO = NSEntityDescription.insertNewObject(forEntityName: "ImageMO", into: CoreDataManager.manager.defaultContext) as? ImageMO {
                
                    object.id = image.id
                    object.name = image.title
                    object.isFav = isFav
                    
                    saveContext()
                    
                }
            }
        } catch {}
    }
    
    func getFavoriteStatus(for id: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageMO")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        do {
            if let response = try _workerContext.fetch(fetchRequest) as? [ImageMO] {
                return response.first?.isFav ?? false
            }
        } catch { return false }
        return false
    }
    
    private func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do{
                try context.save()
            } catch {
                print("Error in saving")
            }
        }
    }
    
    private func saveContext() {
        if defaultContext.hasChanges {
            do{
                try defaultContext.save()
            } catch {
                print("Error in saving")
            }
        }
    }
    
    
    @objc private func contextDidSaveMainQueueContext(_ notification:Notification) {
        
        self._writerContext.perform { [unowned self] in
            self._writerContext.mergeChanges(fromContextDidSave: notification)
            
            if self._writerContext.hasChanges {
                do{
                    try self._writerContext.save()
                    self._writerContext.reset()
                } catch {
                    print("Error in saving")
                }
            }
        }
    }
}
