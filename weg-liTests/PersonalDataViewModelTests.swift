//
//  PersonalDataViewModelTests.swift
//  weg-liTests
//
//  Created by Malte Bünz on 09.07.20.
//  Copyright © 2020 Martin Wilhelmi. All rights reserved.
//

@testable import weg_li
import XCTest

class PersonalDataViewModelTests: XCTestCase {
    var sut: PersonalDataViewModel!

    func testIsValidShouldBeFalseWhenContactIsNil() {
        sut = PersonalDataViewModel(model: nil)

        let cancellable = sut.$isFormValid
            .sink(receiveValue: { XCTAssertFalse($0) })

        XCTAssertNotNil(cancellable)
    }
}
