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
        case name(String, NWInterface?)

        // Network strangely makes this initializer non-failable
        public init(_ string: String)
        {
            if string.contains(":")
            {
                if let address = IPv6Address(string)
                {
                    self = .ipv6(address)
                }
                else
                {
                    self = .name(string, nil)
                }
            }
            else
            {
                if let address = IPv4Address(string)
                {
                    self = .ipv4(address)
                }
                else
                {
                    self = .name(string, nil)
                }
            }
        }
    }
    
    public struct Port
    {
        public var rawValue: UInt16
        
        public init(integerLiteral: UInt16)
        {
            self.rawValue = integerLiteral
        }
        
        // This label coincides with Apple's NWEndpoint.Port initializer
        public init(rawValue: UInt16)
        {
            self.rawValue = rawValue
        }
    }
    
    case hostPort(host: NWEndpoint.Host, port: NWEndpoint.Port)
}
