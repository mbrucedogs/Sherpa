import XCTest
@testable import Sherpa

final class SherpaTests: XCTestCase {
    
    @MainActor
    func testSherpaInitialization() {
        let sherpa = Sherpa()
        XCTAssertFalse(sherpa.isActive)
        XCTAssertEqual(sherpa.state, .hidden)
        XCTAssertNil(sherpa.currentStepIndex)
        XCTAssertEqual(sherpa.totalSteps, 0)
    }
    
    @MainActor
    func testConfigurationPresets() {
        let defaultConfig = SherpaConfiguration.default
        XCTAssertTrue(defaultConfig.showHighlightRing)
        XCTAssertTrue(defaultConfig.hapticsEnabled)
        
        let minimalConfig = SherpaConfiguration.minimal
        XCTAssertFalse(minimalConfig.showHighlightRing)
        XCTAssertFalse(minimalConfig.hapticsEnabled)
        
        let boldConfig = SherpaConfiguration.bold
        XCTAssertTrue(boldConfig.showHighlightRing)
        XCTAssertGreaterThan(boldConfig.spotlightPadding, defaultConfig.spotlightPadding)
    }
}
