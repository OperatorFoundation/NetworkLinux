//
//  IPv4Address.swift
//  Transport
//
//  Created by Brandon Wiley on 6/12/18.
//

import Foundation

public struct IPv4Address
{
    public var address: String
    public var rawValue: Data
    
    public init?(_ address: String)
    {
        self.address=address
        
        let parts = address.split(separator: ".")
        guard let part0 = UInt8(parts[0]) else { return nil}
        guard let part1 = UInt8(parts[1]) else { return nil}
        guard let part2 = UInt8(parts[2]) else { return nil}
        guard let part3 = UInt8(parts[3]) else { return nil}
        let array = [part0, part1, part2, part3]
        self.rawValue = Data(array)
    
    }
    
    public init?(_ rawValue: Data, _ interface: NWInterface? = nil)
    {
        self.address = String(Int(rawValue[0])) + "." + String(Int(rawValue[1])) + "." + String(Int(rawValue[2])) + "." + String(Int(rawValue[3]))
        self.rawValue = rawValue
    }
}
