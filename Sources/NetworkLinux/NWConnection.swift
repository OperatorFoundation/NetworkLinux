//
//  NetworkConnection.swift
//  TransportPackageDescription
//
//  Created by Brandon Wiley on 6/12/18.
//

import Foundation
import Dispatch

import Socket

open class NWConnection
{
    public enum State
    {
        case cancelled
        case failed(NWError)
        case preparing
        case ready
        case setup
        case waiting(NWError)
    }
    
    public enum SendCompletion
    {
        case contentProcessed((NWError?) -> Void)
        case idempotent
    }
    
    public class ContentContext
    {
        public init()
        {
            //
        }
    }
    
    private var usingUDP: Bool
    private var socket: Socket
    private var queue: DispatchQueue?
    
    public init?(host: NWEndpoint.Host, port: NWEndpoint.Port, using: NWParameters)
    {
        usingUDP = false
        
        if let prot = using.defaultProtocolStack.internetProtocol
        {
            if let _ = prot as? NWProtocolUDP.Options {
                usingUDP = true
            }
        }
        
        if(usingUDP)
        {
            //FIXME: add udp functionality
            return nil
        }
        else
        {
            guard let socket = try? Socket.create() else {return nil}
            self.socket = socket
            
            do
            {
                
                switch host
                {
                case .ipv4(let ipv4):
                    try self.socket.connect(to: ipv4.address, port: Int32(port.rawValue))
                default:
                    return nil
                }
            }
            catch
            {
                return nil
            }
        }
        
        if let viability = viabilityUpdateHandler {
            viability(true)
        }
        
        if let state = stateUpdateHandler {
            state(.ready)
        }
    }
    
    public func start(queue: DispatchQueue)
    {
        self.queue=queue
        
        if let viability = viabilityUpdateHandler {
            viability(true)
        }
        
        if let state = stateUpdateHandler {
            state(.ready)
        }
    }
    
    public func cancel()
    {
        if let state = stateUpdateHandler
        {
            state(.cancelled)
        }
    }
    
    public var stateUpdateHandler: ((NWConnection.State) -> Void)?
    public var viabilityUpdateHandler: ((Bool) -> Void)?
    
    public func send(content: Data?, contentContext: NWConnection.ContentContext, isComplete: Bool, completion: NWConnection.SendCompletion)
    {
        if let data = content
        {
            do
            {
                try self.socket.write(from: data)
                
                switch completion
                {
                    case .contentProcessed(let callback):
                            callback(nil)
                    case .idempotent:
                        return
                }
            }
            catch
            {
                switch completion
                {
                    case .contentProcessed(let callback):
                        let nwerr = NWError.posix(POSIXErrorCode.ECONNREFUSED)
                        callback(nwerr);
                    case .idempotent:
                        return
                }
            }
        }
    }
    
    public func receive(completion: @escaping (Data?, NWConnection.ContentContext?, Bool, NWError?) -> Void)
    {
        receive(minimumIncompleteLength: 1, maximumLength: 1024)
        {
            (data, context, isComplete, error) in
            
            guard error == nil else {
                completion(nil, context, isComplete, error)
                return
            }
            
            guard data != nil else {
                completion(nil, context, isComplete, nil)
                return
            }
            
            completion(data, context, isComplete, nil)
        }
    }
    
    public func receive(minimumIncompleteLength: Int, maximumLength: Int, completion: @escaping (Data?, NWConnection.ContentContext?, Bool, NWError?) -> Void)
    {
        var data = Data()
        
        do
        {
            let _ = try self.socket.read(into: &data)
            completion(data, nil, false, nil)
            return
        }
        catch
        {
            let nwerr = NWError.posix(POSIXErrorCode.ECONNREFUSED)
            completion(nil, nil, true, nwerr)
            return
        }
    }
    
    
}
