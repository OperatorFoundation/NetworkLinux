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
            //FIXME: add udp functionality
            throw NWError.posix(POSIXErrorCode.EBADF)
//            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
//            let bootstrap = DatagramBootstrap(group: group)
//                // Enable SO_REUSEADDR.
//                .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
//                .channelInitializer
//                {
//                    channel in
//
//                    channel.pipeline.add(handler: Handler<ByteBuffer>())
//                }
//
//            defer
//            {
//                try! group.syncShutdownGracefully()
//            }
//
//            channel = try! bootstrap.bind(host: "127.0.0.1", port: 2079).wait()
//            /* the Channel is now ready to send/receive datagrams */
        }
        else
        {
            guard let socket = try? Socket.create() else {
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
