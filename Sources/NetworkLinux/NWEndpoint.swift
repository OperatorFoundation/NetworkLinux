//
//  NWEndpoint.swift
//  Transport
//
//  Created by Brandon Wiley on 6/12/18.
//

import Foundation

public enum NWEndpoint
{
    public enum Host
    {
        case ipv4(IPv4Address)
        case ipv6(IPv6Address)
    }
    
    public struct Port
    {
        public var rawValue: UInt16
        
        public init(integerLiteral: UInt16)
        {
            self.rawValue=integerLiteral
        }
    }
    
    case hostPort(host: NWEndpoint.Host, port: NWEndpoint.Port)
}
