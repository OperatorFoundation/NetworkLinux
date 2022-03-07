//
//  NWEndpoint.swift
//  Transport
//
//  Created by Brandon Wiley on 6/12/18.
//

import Foundation

public enum NWEndpoint: Equatable
{
    public enum Host: Equatable
    {
        public static func == (lhs: NWEndpoint.Host, rhs: NWEndpoint.Host) -> Bool {
            switch lhs {
                case .ipv4(let leftIPv4):
                    switch rhs {
                        case .ipv4(let rightIPv4):
                            return leftIPv4 == rightIPv4
                        default:
                            return false
                    }
                case .ipv6(let leftIPv6):
                    switch rhs {
                        case .ipv6(let rightIPv6):
                            return leftIPv6 == rightIPv6
                        default:
                            return false
                    }
                case .name(let leftNameString, _):
                    switch rhs {
                        case .name(let rightNameString, _):
                            return leftNameString == rightNameString
                        default:
                            return false
                    }
            }
        }
        
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
    
    public struct Port: Equatable
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
