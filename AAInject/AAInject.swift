//
//  AAInject.swift
//  AAInject
//
//  Created by David Godfrey on 21/10/2017.
//  Copyright © 2017 Alliterative Animals. All rights reserved.
//

import Foundation

class AAInjector {
    typealias FactoryFunction = (AAInjector) throws -> Any
    private var knownFactories: [ String : FactoryFunction ] = [:]
    private var cachedServices: [ String : Any ] = [:]
    private var knownProperties: [ String : Any ] = [:]
    
    init() {}
    
    private func typeToString<Service>(_ serviceType: Service.Type) -> String {
        return "\(serviceType)"
    }
    
    func inject<Service: AnyObject>(_ serviceType: Service.Type) throws -> Service {
        let serviceKey = self.typeToString(serviceType)
        
        guard !(self.cachedServices[serviceKey] is Service) else {
            return self.cachedServices[serviceKey]! as! Service
        }
        guard let factory = self.knownFactories[serviceKey] else {
            throw AAInjectorError.ServiceNotRegistered(serviceKey: serviceKey)
        }
        
        let result = (try factory(self)) as! Service
        
        self.cachedServices.updateValue(result, forKey: serviceKey)
        
        return result
    }
    
    func setProperty(_ key: String, value: Any) -> Void {
        self.knownProperties.updateValue(value, forKey: key)
    }
    
    func getProperty<T>(_ key: String) throws -> T {
        guard let rawProperty = self.knownProperties[key] else {
            throw AAInjectorError.PropertyNotRegistered(propertyKey: key)
        }
        
        guard let property = rawProperty as? T else {
            throw AAInjectorError.PropertyTypeMismatch(
                propertyKey: key,
                expectedType: String(describing: T.self),
                actualType: String(describing: type(of: rawProperty))
            )
        }
        
        return property
    }
    
    func register<Service>(_ serviceType: Service.Type, factory: @escaping (AAInjector) throws -> Service) {
        self.knownFactories.updateValue(factory, forKey: self.typeToString(serviceType))
    }
}

enum AAInjectorError: Error {
    case ServiceNotRegistered(serviceKey: String)
    case PropertyNotRegistered(propertyKey: String)
    case PropertyTypeMismatch(propertyKey: String, expectedType: String, actualType: String)
}

