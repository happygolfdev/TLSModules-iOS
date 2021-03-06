//
//  URLAttachment.swift
//  TLSModules
//
//  Created by Justin Ji on 2020/02/26.
//

import Foundation

/**
 로컬에 저장되어 있는  미디어 파일 URL에서 데이터를 가져와 첨부 데이터 모델
*/
open class URLAttachment: MediumAttachment {
    public var url: URL
    public var name: String
    public var fileName: String
    public var type: MediumType
    
    public init(url: URL,
                name: String,
                fileName: String,
                type: MediumType) {
        
        self.url = url
        self.name = name
        self.fileName = fileName
        self.type = type
    }
}
