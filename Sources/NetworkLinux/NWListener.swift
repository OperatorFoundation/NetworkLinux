//
//  NWListener.swift
//  Network
//
//  Created by Brandon Wiley on 9/4/18.
//

import Foundation
import Socket
import Dispatch

public class NWListener
{
    public enum State
    {
        case cancelled
        case failed(NWError)
        case ready
        case setup
        case waiting(NWError)
    }
    
    public var debugDescription: String = "[NWListener]"
    public var newConnectionHandler: ((NWConnection) -> Void)?
    public let parameters: NWParameters
    public var port: NWEndpoint.Port?
    public var queue: DispatchQueue?
    public var stateUpdateHandler: ((NWListener.State) -> Void)?

    private var usingUDP: Bool
    private var socket: Socket
    
    // Note: It is unclear from the documentation how to use the Network framework to listen on a IPv6 address, or if this is even possible.
    // Therefore, this is not currently supported in NetworkLinux.
    public required init(using: NWParameters, on port: NWEndpoint.Port) throws
    {
        self.parameters=using
        self.port=port
        
        print("Port: \(String(describing: self.port))")
        
        usingUDP = false
        
        if let prot = using.defaultProtocolStack.internetProtocol
        {
            if let _ = prot as? NWProtocolUDP.Options {
                usingUDP = true
            }
        }
        
        if(usingUDP)
        {
            guard let socket = try? Socket.create(family: Socket.ProtocolFamily.inet, type: Socket.SocketType.datagram, proto: .udp) else {
                throw NWError.posix(POSIXErrorCode.EADDRINUSE)
            }
            self.socket = socket
            
            do
            {
                try socket.listen(on: Int(port.rawValue))
            }
            catch
            {
                throw NWError.posix(POSIXErrorCode.EADDRINUSE)
            }
        }
        else
        {
            guard let socket = try? Socket.create(family: Socket.ProtocolFamily.inet, type: Socket.SocketType.stream, proto: .tcp) else {
                throw NWError.posix(POSIXErrorCode.EADDRINUSE)
            }
            self.socket = socket
            
            do
            {
                try socket.listen(on: Int(port.rawValue), node: "0.0.0.0")
            }
            catch
            {
                throw NWError.posix(POSIXErrorCode.EADDRINUSE)
            }
        }
    }
    
    public func start(queue: DispatchQueue)
    {
        if let state = stateUpdateHandler {
            state(.ready)
        }
    }
    
    public func cancel()
    {
        if let state = stateUpdateHandler {
            state(.cancelled)
        }
    }
}
