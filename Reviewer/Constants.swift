//
//  Constants.swift
//  Reviewer
//
//  Created by Horus on 4/12/24.
//

import Foundation

struct Constants {
    static let tastes: [String] = ["계란맛", "단맛", "짭짤함", "산미", "쓴맛", "감칠맛", "간장맛", "된장맛", "매콤함", "떫은맛", "텁텁함", "시원함", "기름기", "익힌 생선 살맛", "등푸른생선 살맛(약함)", "등푸른생선 살맛(강함)", "흰살생선 단맛", "불에 그을린 맛", "풍미", "꾸덕함", "부드러운 식감", "쫄깃함", "씹는맛", "찰짐", "질김", "고소한 맛", "온도감", "차가운", "가쓰오다시", "마늘맛", "유즈코쇼", "시소향", "해수맛", "실패한 성게", "알싸한 맛", "강한 초맛", "비린맛", "갑각류 살맛(약함)", "갑각류 살맛(강함)"]
    
    static let tastesSections: [TastesSection] = [.init(categoryIndex: 0, title: "기본", tastes: ["단맛(약함)", "단맛(적당)", "단맛(강함)", "짭짤함(약함)", "짭짤함(적당)", "짭짤함(강함)", "산미(약함)", "산미(적당)", "산미(강함)", "감칠맛", "쓴맛", "매콤함", "떫은맛", "비린맛", "고소한맛"]), .init(categoryIndex: 1, title: "일본식 계란찜", tastes: ["내용물이 적은", "내용물이 많은", "가쓰오부시 앙소스", "계란맛(약함)", "계란맛(적당)", "계란맛(강함)", "치즈맛(약함)", "치즈맛(적당)", "치즈맛(강함)"]), .init(categoryIndex: 2, title: "샤리", tastes: ["담백함", "적당함", "단맛", "강한", "소금 강한", "식초 강한", "소금, 식초 둘 다 강한"]), .init(categoryIndex: 3, title: "질감", tastes: ["부드러운", "쫄깃함", "씹는맛", "찰짐", "질김", "꾸덕함", "서걱함", "녹진함", "탱글함"]), .init(categoryIndex: 4, title: "흰살생선", tastes: ["흰살생선 단맛(약함)", "흰살생선 단맛(적당)", "흰살생선 단맛(강함)", "시원함"]), .init(categoryIndex: 5, title: "등푸른생선", tastes: ["등푸른생선 살맛(약함)", "등푸른생선 살맛(적당)", "등푸른생선 살맛(강함)", "기름기"]), .init(categoryIndex: 6, title: "참치, 방어, 잿방어", tastes: ["산미(약함)", "산미(적당)", "산미(강함)", "기름기(약함)", "기름기(적당)", "기름기(강함)", "철분맛(약함)", "철분맛(적당)", "철분맛(강함)", "입에서 녹는"]), .init(categoryIndex: 7, title: "오징어, 문어", tastes: ["이도기리", "칼집"]), .init(categoryIndex: 8, title: "갑각류", tastes: ["새우 살맛(약함)", "새우 살맛(적당)", "새우 살맛(강함)", "새우 내장맛(약함)", "새우 내장맛(적당)", "새우 내장맛(강함)", "게 살맛(약함)", "게 살맛(적당)", "게 살맛(강함)", "게 내장맛(약함)", "게 내장맛(적당)", "게 내장맛(강함)"]), .init(categoryIndex: 9, title: "조개류", tastes: ["조개 살맛(약함)", "조개 살맛(적당)", "조개 살맛(강함)", "수박, 오이향"]), .init(categoryIndex: 10, title: "야꾸미", tastes: ["시소향", "마늘맛", "유즈코쇼", "발사믹"]), .init(categoryIndex: 11, title: "아부리, 마스까와", tastes: ["지방 녹은 맛", "훈연향", "익힌 생선 살맛", "탄맛"]), .init(categoryIndex: 12, title: "온도감", tastes: ["차가운", "적당한 온도감", "따뜻한", "뜨거운", "식은"]), .init(categoryIndex: 13, title: "제스트", tastes: ["치즈맛(약함)", "치즈맛(적당)", "치즈맛(강함)", "유자껍질향(약함)", "유자껍질향(적당)", "유자껍질향(강함)", "청귤껍질향(약함)", "청귤껍질향(적당)", "청귤껍질향(강함)"]), .init(categoryIndex: 14, title: "소스, 면, 국", tastes: ["가쓰오부시 다시마 육수(약함)", "가쓰오부시 다시마 육수(적당)", "가쓰오부시 다시마 육수(강함)", "닭 육수", "소고기 육수", "돼지고기 육수", "표고향(약함)", "표고향(적당)", "표고향(강함)"]), .init(categoryIndex: 15, title: "된장, 간장", tastes: ["된장맛(약함)", "된장맛(적당)", "된장맛(강함)", "간장맛(약함)", "간장맛(적당)", "간장맛(강함)", "간장 감칠맛"]), .init(categoryIndex: 16, title: "붕장어, 민물장어", tastes: ["소금", "타래소스"]), .init(categoryIndex: 17, title: "성게, 아귀간", tastes: ["해수맛", "풍미", "실패한 성게맛", "달달함"])]
}
