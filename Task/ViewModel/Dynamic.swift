//
//  Dynamic.swift
//  Task
//
//  Created by Amitabha Saha on 15/12/21.
//

import Foundation

open class Dynamic<T> {
    
    public enum Source{
        case model, user
    }
    /**
     Every value that is set to this property can have two sources either model or from the User.
     valueSource maintains that
     */
    open var valueSource: Source = .model
    
    
    public typealias Listener = (T?) -> Void
    open var listener: Listener?
    
    open var value: T?{
        didSet{
            listener?(value)
        }
    }
    
    public func setValue(value: T?,
                  source: Source){
        self.valueSource = source
        self.value = value
    }
    
    public init(_ value: T? = nil) {
        self.value = value
    }
    
    //TODO:- Debaditya - Add weak self to avoid strong reference cycles
    
    /**
     Be careful when binding listeners, it should not have any strong references.
     */
    public func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
