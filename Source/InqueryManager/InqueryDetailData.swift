//
//  InqueryDetailDat.swift
//  Alamofire
//
//  Created by Justin Ji on 23/08/2019.
//

import Foundation

@available(*, deprecated, message: "View-related classes are not supported.")
/// 문의사항의 디테일 화면에서 필요한 Attributes의 데이터 모델
internal class InquiryDetailData: ContentDetailData {
    var answerTextColor = UIColor.white
    var answerFont = UIFont.systemFont(ofSize: 13.0, weight: .regular)
    var answerBackgroundColor = UIColor.init(hexString: "2359CB")
}
