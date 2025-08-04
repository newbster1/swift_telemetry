import Foundation
import SwiftProtobuf

// MARK: - OTLP Protocol Buffer Models

/// OTLP ExportTraceServiceRequest - Root message for trace export
public struct OTLPExportTraceServiceRequest {
    public var resourceSpans: [OTLPResourceSpans]
    
    public init(resourceSpans: [OTLPResourceSpans]) {
        self.resourceSpans = resourceSpans
    }
    
    public func serializedData() throws -> Data {
        // Create protobuf message
        var message = Opentelemetry_Proto_Collector_Trace_V1_ExportTraceServiceRequest()
        message.resourceSpans = resourceSpans.map { $0.toProto() }
        return try message.serializedData()
    }
}

/// OTLP ResourceSpans - Contains resource and scope spans
public struct OTLPResourceSpans {
    public var resource: OTLPResource
    public var scopeSpans: [OTLPScopeSpans]
    
    public init(resource: OTLPResource, scopeSpans: [OTLPScopeSpans]) {
        self.resource = resource
        self.scopeSpans = scopeSpans
    }
    
    func toProto() -> Opentelemetry_Proto_Trace_V1_ResourceSpans {
        var proto = Opentelemetry_Proto_Trace_V1_ResourceSpans()
        proto.resource = resource.toProto()
        proto.scopeSpans = scopeSpans.map { $0.toProto() }
        return proto
    }
}

/// OTLP Resource - Contains resource attributes
public struct OTLPResource {
    public var attributes: [String: String]
    
    public init(attributes: [String: String]) {
        self.attributes = attributes
    }
    
    func toProto() -> Opentelemetry_Proto_Resource_V1_Resource {
        var proto = Opentelemetry_Proto_Resource_V1_Resource()
        proto.attributes = attributes.map { key, value in
            var kv = Opentelemetry_Proto_Common_V1_KeyValue()
            kv.key = key
            kv.value.stringValue = value
            return kv
        }
        return proto
    }
}

/// OTLP ScopeSpans - Contains spans for a specific scope
public struct OTLPScopeSpans {
    public var spans: [OTLPSpan]
    
    public init(spans: [OTLPSpan]) {
        self.spans = spans
    }
    
    func toProto() -> Opentelemetry_Proto_Trace_V1_ScopeSpans {
        var proto = Opentelemetry_Proto_Trace_V1_ScopeSpans()
        proto.spans = spans.map { $0.toProto() }
        return proto
    }
}

/// OTLP Span - Individual span data
public struct OTLPSpan {
    public var traceId: Data
    public var spanId: Data
    public var name: String
    public var startTimeUnixNano: UInt64
    public var endTimeUnixNano: UInt64
    public var attributes: [OTLPKeyValue]
    
    public init(
        traceId: Data,
        spanId: Data,
        name: String,
        startTimeUnixNano: UInt64,
        endTimeUnixNano: UInt64,
        attributes: [OTLPKeyValue]
    ) {
        self.traceId = traceId
        self.spanId = spanId
        self.name = name
        self.startTimeUnixNano = startTimeUnixNano
        self.endTimeUnixNano = endTimeUnixNano
        self.attributes = attributes
    }
    
    func toProto() -> Opentelemetry_Proto_Trace_V1_Span {
        var proto = Opentelemetry_Proto_Trace_V1_Span()
        proto.traceID = traceId
        proto.spanID = spanId
        proto.name = name
        proto.startTimeUnixNano = startTimeUnixNano
        proto.endTimeUnixNano = endTimeUnixNano
        proto.attributes = attributes.map { $0.toProto() }
        return proto
    }
}

/// OTLP KeyValue - Key-value pair for attributes
public struct OTLPKeyValue {
    public var key: String
    public var value: OTLPAnyValue
    
    public init(key: String, value: OTLPAnyValue) {
        self.key = key
        self.value = value
    }
    
    func toProto() -> Opentelemetry_Proto_Common_V1_KeyValue {
        var proto = Opentelemetry_Proto_Common_V1_KeyValue()
        proto.key = key
        proto.value = value.toProto()
        return proto
    }
}

/// OTLP AnyValue - Can hold different types of values
public struct OTLPAnyValue {
    public var stringValue: String?
    public var intValue: Int64?
    public var doubleValue: Double?
    public var boolValue: Bool?
    
    public init(stringValue: String? = nil, intValue: Int64? = nil, doubleValue: Double? = nil, boolValue: Bool? = nil) {
        self.stringValue = stringValue
        self.intValue = intValue
        self.doubleValue = doubleValue
        self.boolValue = boolValue
    }
    
    func toProto() -> Opentelemetry_Proto_Common_V1_AnyValue {
        var proto = Opentelemetry_Proto_Common_V1_AnyValue()
        
        if let stringValue = stringValue {
            proto.stringValue = stringValue
        } else if let intValue = intValue {
            proto.intValue = intValue
        } else if let doubleValue = doubleValue {
            proto.doubleValue = doubleValue
        } else if let boolValue = boolValue {
            proto.boolValue = boolValue
        }
        
        return proto
    }
}

// MARK: - Generated Protocol Buffer Messages
// These would normally be generated from .proto files, but we'll define them here for simplicity

public struct Opentelemetry_Proto_Collector_Trace_V1_ExportTraceServiceRequest {
    public var resourceSpans: [Opentelemetry_Proto_Trace_V1_ResourceSpans] = []
    
    public init() {}
    
    public func serializedData() throws -> Data {
        // Simple protobuf serialization
        var data = Data()
        
        // Write resourceSpans field (field number 1, wire type 2 for length-delimited)
        for resourceSpan in resourceSpans {
            let spanData = try resourceSpan.serializedData()
            data.append(encodeFieldHeader(fieldNumber: 1, wireType: 2))
            data.append(encodeVarint(UInt64(spanData.count)))
            data.append(spanData)
        }
        
        return data
    }
    
    private func encodeFieldHeader(fieldNumber: Int, wireType: Int) -> Data {
        let tag = (fieldNumber << 3) | wireType
        return encodeVarint(UInt64(tag))
    }
    
    private func encodeVarint(_ value: UInt64) -> Data {
        var data = Data()
        var v = value
        
        while v >= 0x80 {
            data.append(UInt8((v & 0x7F) | 0x80))
            v >>= 7
        }
        data.append(UInt8(v & 0x7F))
        
        return data
    }
}

public struct Opentelemetry_Proto_Trace_V1_ResourceSpans {
    public var resource: Opentelemetry_Proto_Resource_V1_Resource
    public var scopeSpans: [Opentelemetry_Proto_Trace_V1_ScopeSpans] = []
    
    public init() {
        self.resource = Opentelemetry_Proto_Resource_V1_Resource()
    }
    
    public func serializedData() throws -> Data {
        var data = Data()
        
        // Write resource field
        let resourceData = try resource.serializedData()
        data.append(encodeFieldHeader(fieldNumber: 1, wireType: 2))
        data.append(encodeVarint(UInt64(resourceData.count)))
        data.append(resourceData)
        
        // Write scopeSpans field
        for scopeSpan in scopeSpans {
            let spanData = try scopeSpan.serializedData()
            data.append(encodeFieldHeader(fieldNumber: 2, wireType: 2))
            data.append(encodeVarint(UInt64(spanData.count)))
            data.append(spanData)
        }
        
        return data
    }
    
    private func encodeFieldHeader(fieldNumber: Int, wireType: Int) -> Data {
        let tag = (fieldNumber << 3) | wireType
        return encodeVarint(UInt64(tag))
    }
    
    private func encodeVarint(_ value: UInt64) -> Data {
        var data = Data()
        var v = value
        
        while v >= 0x80 {
            data.append(UInt8((v & 0x7F) | 0x80))
            v >>= 7
        }
        data.append(UInt8(v & 0x7F))
        
        return data
    }
}

public struct Opentelemetry_Proto_Resource_V1_Resource {
    public var attributes: [Opentelemetry_Proto_Common_V1_KeyValue] = []
    
    public init() {}
    
    public func serializedData() throws -> Data {
        var data = Data()
        
        for attribute in attributes {
            let attrData = try attribute.serializedData()
            data.append(encodeFieldHeader(fieldNumber: 1, wireType: 2))
            data.append(encodeVarint(UInt64(attrData.count)))
            data.append(attrData)
        }
        
        return data
    }
    
    private func encodeFieldHeader(fieldNumber: Int, wireType: Int) -> Data {
        let tag = (fieldNumber << 3) | wireType
        return encodeVarint(UInt64(tag))
    }
    
    private func encodeVarint(_ value: UInt64) -> Data {
        var data = Data()
        var v = value
        
        while v >= 0x80 {
            data.append(UInt8((v & 0x7F) | 0x80))
            v >>= 7
        }
        data.append(UInt8(v & 0x7F))
        
        return data
    }
}

public struct Opentelemetry_Proto_Trace_V1_ScopeSpans {
    public var spans: [Opentelemetry_Proto_Trace_V1_Span] = []
    
    public init() {}
    
    public func serializedData() throws -> Data {
        var data = Data()
        
        for span in spans {
            let spanData = try span.serializedData()
            data.append(encodeFieldHeader(fieldNumber: 1, wireType: 2))
            data.append(encodeVarint(UInt64(spanData.count)))
            data.append(spanData)
        }
        
        return data
    }
    
    private func encodeFieldHeader(fieldNumber: Int, wireType: Int) -> Data {
        let tag = (fieldNumber << 3) | wireType
        return encodeVarint(UInt64(tag))
    }
    
    private func encodeVarint(_ value: UInt64) -> Data {
        var data = Data()
        var v = value
        
        while v >= 0x80 {
            data.append(UInt8((v & 0x7F) | 0x80))
            v >>= 7
        }
        data.append(UInt8(v & 0x7F))
        
        return data
    }
}

public struct Opentelemetry_Proto_Trace_V1_Span {
    public var traceID: Data = Data()
    public var spanID: Data = Data()
    public var name: String = ""
    public var startTimeUnixNano: UInt64 = 0
    public var endTimeUnixNano: UInt64 = 0
    public var attributes: [Opentelemetry_Proto_Common_V1_KeyValue] = []
    
    public init() {}
    
    public func serializedData() throws -> Data {
        var data = Data()
        
        // Write traceID
        if !traceID.isEmpty {
            data.append(encodeFieldHeader(fieldNumber: 1, wireType: 2))
            data.append(encodeVarint(UInt64(traceID.count)))
            data.append(traceID)
        }
        
        // Write spanID
        if !spanID.isEmpty {
            data.append(encodeFieldHeader(fieldNumber: 2, wireType: 2))
            data.append(encodeVarint(UInt64(spanID.count)))
            data.append(spanID)
        }
        
        // Write name
        if !name.isEmpty {
            data.append(encodeFieldHeader(fieldNumber: 3, wireType: 2))
            let nameData = name.data(using: .utf8) ?? Data()
            data.append(encodeVarint(UInt64(nameData.count)))
            data.append(nameData)
        }
        
        // Write startTimeUnixNano
        if startTimeUnixNano != 0 {
            data.append(encodeFieldHeader(fieldNumber: 4, wireType: 0))
            data.append(encodeVarint(startTimeUnixNano))
        }
        
        // Write endTimeUnixNano
        if endTimeUnixNano != 0 {
            data.append(encodeFieldHeader(fieldNumber: 5, wireType: 0))
            data.append(encodeVarint(endTimeUnixNano))
        }
        
        // Write attributes
        for attribute in attributes {
            let attrData = try attribute.serializedData()
            data.append(encodeFieldHeader(fieldNumber: 6, wireType: 2))
            data.append(encodeVarint(UInt64(attrData.count)))
            data.append(attrData)
        }
        
        return data
    }
    
    private func encodeFieldHeader(fieldNumber: Int, wireType: Int) -> Data {
        let tag = (fieldNumber << 3) | wireType
        return encodeVarint(UInt64(tag))
    }
    
    private func encodeVarint(_ value: UInt64) -> Data {
        var data = Data()
        var v = value
        
        while v >= 0x80 {
            data.append(UInt8((v & 0x7F) | 0x80))
            v >>= 7
        }
        data.append(UInt8(v & 0x7F))
        
        return data
    }
}

public struct Opentelemetry_Proto_Common_V1_KeyValue {
    public var key: String = ""
    public var value: Opentelemetry_Proto_Common_V1_AnyValue
    
    public init() {
        self.value = Opentelemetry_Proto_Common_V1_AnyValue()
    }
    
    public func serializedData() throws -> Data {
        var data = Data()
        
        // Write key
        if !key.isEmpty {
            data.append(encodeFieldHeader(fieldNumber: 1, wireType: 2))
            let keyData = key.data(using: .utf8) ?? Data()
            data.append(encodeVarint(UInt64(keyData.count)))
            data.append(keyData)
        }
        
        // Write value
        let valueData = try value.serializedData()
        data.append(encodeFieldHeader(fieldNumber: 2, wireType: 2))
        data.append(encodeVarint(UInt64(valueData.count)))
        data.append(valueData)
        
        return data
    }
    
    private func encodeFieldHeader(fieldNumber: Int, wireType: Int) -> Data {
        let tag = (fieldNumber << 3) | wireType
        return encodeVarint(UInt64(tag))
    }
    
    private func encodeVarint(_ value: UInt64) -> Data {
        var data = Data()
        var v = value
        
        while v >= 0x80 {
            data.append(UInt8((v & 0x7F) | 0x80))
            v >>= 7
        }
        data.append(UInt8(v & 0x7F))
        
        return data
    }
}

public struct Opentelemetry_Proto_Common_V1_AnyValue {
    public var stringValue: String = ""
    public var intValue: Int64 = 0
    public var doubleValue: Double = 0.0
    public var boolValue: Bool = false
    
    public init() {}
    
    public func serializedData() throws -> Data {
        var data = Data()
        
        // Write stringValue if present
        if !stringValue.isEmpty {
            data.append(encodeFieldHeader(fieldNumber: 1, wireType: 2))
            let stringData = stringValue.data(using: .utf8) ?? Data()
            data.append(encodeVarint(UInt64(stringData.count)))
            data.append(stringData)
        }
        
        // Write intValue if present
        if intValue != 0 {
            data.append(encodeFieldHeader(fieldNumber: 2, wireType: 0))
            data.append(encodeVarint(UInt64(bitPattern: intValue)))
        }
        
        // Write doubleValue if present
        if doubleValue != 0.0 {
            data.append(encodeFieldHeader(fieldNumber: 3, wireType: 1))
            data.append(withUnsafeBytes(of: doubleValue) { Data($0) })
        }
        
        // Write boolValue if present
        if boolValue {
            data.append(encodeFieldHeader(fieldNumber: 4, wireType: 0))
            data.append(encodeVarint(1))
        }
        
        return data
    }
    
    private func encodeFieldHeader(fieldNumber: Int, wireType: Int) -> Data {
        let tag = (fieldNumber << 3) | wireType
        return encodeVarint(UInt64(tag))
    }
    
    private func encodeVarint(_ value: UInt64) -> Data {
        var data = Data()
        var v = value
        
        while v >= 0x80 {
            data.append(UInt8((v & 0x7F) | 0x80))
            v >>= 7
        }
        data.append(UInt8(v & 0x7F))
        
        return data
    }
}