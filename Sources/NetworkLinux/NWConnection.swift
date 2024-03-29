//
//  NetworkConnection.swift
//  TransportPackageDescription
//
//  Created by Brandon Wiley on 6/12/18.
//

import Foundation
import Dispatch

import Socket

public class NWConnection
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
        public static let defaultMessage = NWConnection.ContentContext(identifier: "defaultMessage")
        
        public static let finalMessage = NWConnection.ContentContext(identifier: "finalMessage")

        public static let defaultStream = NWConnection.ContentContext(identifier: "defaultStream")
        
        public init(identifier: String, expiration: UInt64 = 0, priority: Double = 0.5, isFinal: Bool = false, antecedent: NWConnection.ContentContext? = nil, metadata: [NWProtocolMetadata]? = [])
        {
            
        }
    }
    
    private var usingUDP: Bool
    private var socket: Socket? = nil
    private var queue: DispatchQueue?
    
    public init(host: NWEndpoint.Host, port: NWEndpoint.Port, using: NWParameters)
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
            do
            {
                switch host
                {
                    case .ipv4(let ipv4):
                        guard let socket = try? Socket.create(family: Socket.ProtocolFamily.inet, type: Socket.SocketType.datagram, proto: Socket.SocketProtocol.udp) else {return}
                        self.socket = socket
                        try socket.connect(to: ipv4.address, port: Int32(port.rawValue))
                    case .ipv6(let ipv6):
                        guard let socket = try? Socket.create(family: Socket.ProtocolFamily.inet6, type: Socket.SocketType.datagram, proto: Socket.SocketProtocol.udp) else {return}
                        self.socket = socket
                        try socket.connect(to: ipv6.address, port: Int32(port.rawValue))
                    default:
                        return
                }
            }
            catch
            {
                return
            }
        }
        else
        {
            do
            {
                switch host
                {
                    case .ipv4(let ipv4):
                        guard let socket = try? Socket.create(family: Socket.ProtocolFamily.inet, type: Socket.SocketType.stream, proto: Socket.SocketProtocol.tcp) else {return}
                        self.socket = socket
                        try socket.connect(to: ipv4.address, port: Int32(port.rawValue))
                    case .ipv6(let ipv6):
                        guard let socket = try? Socket.create(family: Socket.ProtocolFamily.inet6, type: Socket.SocketType.stream, proto: Socket.SocketProtocol.tcp) else {return}
                        self.socket = socket
                        try socket.connect(to: ipv6.address, port: Int32(port.rawValue))
                    default:
                        return
                }
            }
            catch
            {
                return
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
        
        guard let socket = self.socket else {return}

        if let data = content
        {
            do
            {
                let bytesWritten = try socket.write(from: data)
                print("bytes written: \(bytesWritten) data count: \(data.count) function: \(#function) file: \(#file), line: \(#line)")
                
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
                print("error: \(error) caught in function: \(#function) file: \(#file), line: \(#line)")
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

        guard let socket = self.socket else {return}
        
        do
        {
            let _ = try socket.read(into: &data)
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
