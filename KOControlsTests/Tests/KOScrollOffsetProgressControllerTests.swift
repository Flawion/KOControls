//
//  KOScrollOffsetProgressControllerTests.swift
//  KOControlsTests
//
//  Copyright (c) 2019 Kuba Ostrowski
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import XCTest
@testable import KOControls

final class KOScrollOffsetProgressControllerTests: XCTestCase {
    private var windowSimulator: WindowSimulator!
    private var viewController: UIViewController!
    private var scrollView: UIScrollView!
    private var scrollOffsetProgressController: KOScrollOffsetProgressController!
    private var offsetProgressFromDelegate: CGFloat = 0

    override func setUp() {
        viewController = UIViewController()
        windowSimulator = WindowSimulator(rootViewController: viewController)
        setUpScrollView()
        setUpScrollOffsetProgressController()
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
        super.setUp()
    }

    private func setUpScrollView() {
        scrollView = UIScrollView()
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            viewController.automaticallyAdjustsScrollViewInsets = false
        }
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(scrollView)
        viewController.view.addConstraints([
            scrollView.leftAnchor.constraint(equalTo: viewController.view.leftAnchor),
            scrollView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            scrollView.rightAnchor.constraint(equalTo: viewController.view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
            ])

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        scrollView.addConstraints([
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalToConstant: 4000),
            contentView.heightAnchor.constraint(equalToConstant: 4000)
            ])
    }

    private func setUpScrollOffsetProgressController() {
        scrollOffsetProgressController = KOScrollOffsetProgressController(scrollView: scrollView, minOffset: 200, maxOffset: 500)
        scrollOffsetProgressController.delegate = self
    }

    override func tearDown() {
        super.tearDown()
        scrollOffsetProgressController = nil
        scrollView = nil
        viewController = nil
        windowSimulator = nil
    }

    // MARK: Tests
    func testIsDefaultModeContentOffsetBased() {
        XCTAssertEqual(scrollOffsetProgressController.mode, KOScrollOffsetProgressModes.contentOffsetBased)
    }

    func testIsDefaultAxisVertical() {
         XCTAssertEqual(scrollOffsetProgressController.scrollOffsetAxis, KOScrollOffsetAxis.vertical)
    }

    func testVerticalCalculatingProgressBasedOnScrollOffset() {
        scrollOffsetProgressController.scrollOffsetAxis = .vertical
        checkCalculatingProgressBasedOnScrollOffset()
    }

    func testHorizontalCalculatingProgressBasedOnScrollOffset() {
        scrollOffsetProgressController.scrollOffsetAxis = .horizontal
        checkCalculatingProgressBasedOnScrollOffset()
    }

    private func checkCalculatingProgressBasedOnScrollOffset() {
        scrollOffsetProgressController.mode = .contentOffsetBased
        let minOffset = scrollOffsetProgressController.minOffset
        let maxOffset = scrollOffsetProgressController.maxOffset
        let range = scrollOffsetProgressController.offsetRange
        let halfOffset = minOffset + range / 2

        scrollTo(offset: halfOffset, andCheckProgress: 0.5)
        scrollTo(offset: maxOffset, andCheckProgress: 1.0)
        scrollTo(offset: minOffset, andCheckProgress: 0)
        scrollTo(offset: maxOffset * 2, andCheckProgress: 1.0)
        scrollTo(offset: maxOffset, andCheckProgress: 1.0)
    }

    func testVerticalCalculatingProgressBasedTranslationOffset() {
        scrollOffsetProgressController.scrollOffsetAxis = .vertical
        checkCalculatingProgressBasedTranslationOffset()
    }

    func testHorizontalCalculatingProgressBasedTranslationOffset() {
        scrollOffsetProgressController.scrollOffsetAxis = .horizontal
        checkCalculatingProgressBasedTranslationOffset()
    }

    func checkCalculatingProgressBasedTranslationOffset() {
        scrollOffsetProgressController.mode = .translationOffsetBased
        let minOffset = scrollOffsetProgressController.minOffset
        let maxOffset = scrollOffsetProgressController.maxOffset
        let range = scrollOffsetProgressController.offsetRange

        var currentOffset = maxOffset * 2
        scrollTo(offset: currentOffset, andCheckProgress: 1.0)

        currentOffset -= range / 2
        scrollTo(offset: currentOffset, andCheckProgress: 0.5)

        currentOffset -= range / 2
        scrollTo(offset: currentOffset, andCheckProgress: 0)

        currentOffset -= minOffset
        scrollTo(offset: currentOffset, andCheckProgress: 0)

        currentOffset += minOffset
        scrollTo(offset: currentOffset, andCheckProgress: 0)

        currentOffset += range / 2
        scrollTo(offset: currentOffset, andCheckProgress: 0.5)

        currentOffset += range / 2
        scrollTo(offset: currentOffset, andCheckProgress: 1.0)
    }

    func testVerticalCalculatingProgressWhenScrollingBlockedUntilProgressMax() {
        scrollOffsetProgressController.scrollOffsetAxis = .vertical
        checkCalculatingProgressWhenScrollingBlockedUntilProgressMax()
    }

    func testHorizontalCalculatingProgressWhenScrollingBlockedUntilProgressMax() {
        scrollOffsetProgressController.scrollOffsetAxis = .horizontal
        checkCalculatingProgressWhenScrollingBlockedUntilProgressMax()
    }

    func checkCalculatingProgressWhenScrollingBlockedUntilProgressMax() {
        scrollOffsetProgressController.mode = .scrollingBlockedUntilProgressMax
        let minOffset = scrollOffsetProgressController.minOffset
        let range = scrollOffsetProgressController.offsetRange
        let halfOffset = minOffset + range / 2
        let panGestureRecognizerSimulator = PanGestureRecognizerSimulator()
        scrollOffsetProgressController.testChangeCalculateOffsetGesture(toPanGestureRecognizerMock: panGestureRecognizerSimulator)

        panTo(offset: -halfOffset, gestureRecognizerSimulator: panGestureRecognizerSimulator, andCheckProgress: 0.5)
        scrollTo(offset: 300)
        XCTAssertFalse(isScrollOffsetGreaterThanZero)

        panTo(offset: -range / 2, gestureRecognizerSimulator: panGestureRecognizerSimulator, andCheckProgress: 1.0)
        scrollTo(offset: 300)
        XCTAssertTrue(isScrollOffsetGreaterThanZero)

        panTo(offset: range / 2, gestureRecognizerSimulator: panGestureRecognizerSimulator, andCheckProgress: 1.0)
        XCTAssertTrue(isScrollOffsetGreaterThanZero)

        scrollTo(offset: 0)
        panTo(offset: range / 2, gestureRecognizerSimulator: panGestureRecognizerSimulator, andCheckProgress: 0.5)
        scrollTo(offset: 300)
        XCTAssertFalse(isScrollOffsetGreaterThanZero)

        panTo(offset: range / 2, gestureRecognizerSimulator: panGestureRecognizerSimulator, andCheckProgress: 0)
        scrollTo(offset: 300)
        XCTAssertFalse(isScrollOffsetGreaterThanZero)
    }

    // MARK: Helpers
    private func panTo(offset: CGFloat, gestureRecognizerSimulator: PanGestureRecognizerSimulator, andCheckProgress progress: CGFloat) {
        panTo(offset: offset, gestureRecognizerSimulator: gestureRecognizerSimulator)
        XCTAssertTrue(scrollOffsetProgressController.progress.almostEqual(to: offsetProgressFromDelegate))
        XCTAssertTrue(scrollOffsetProgressController.progress.almostEqual(to: progress))
    }

    private func panTo(offset: CGFloat, gestureRecognizerSimulator: PanGestureRecognizerSimulator) {
        scrollOffsetProgressController.scrollOffsetAxis == .vertical ? panVerticalTo(offset: offset, gestureRecognizerSimulator: gestureRecognizerSimulator) : panHorizontalTo(offset: offset, gestureRecognizerSimulator: gestureRecognizerSimulator)
    }

    private func panVerticalTo(offset: CGFloat, gestureRecognizerSimulator: PanGestureRecognizerSimulator) {
        gestureRecognizerSimulator.setTranslation(CGPoint(x: 0, y: offset), in: scrollView)
        scrollOffsetProgressController.testCalculateOffsetGestureAction()
    }

    private func panHorizontalTo(offset: CGFloat, gestureRecognizerSimulator: PanGestureRecognizerSimulator) {
        gestureRecognizerSimulator.setTranslation(CGPoint(x: offset, y: 0), in: scrollView)
        scrollOffsetProgressController.testCalculateOffsetGestureAction()
    }

    private var isScrollOffsetGreaterThanZero: Bool {
        let offset = scrollOffsetProgressController.scrollOffsetAxis == .vertical ? scrollView.contentOffset.y : scrollView.contentOffset.x
        return offset > 0
    }

    private func scrollTo(offset: CGFloat, andCheckProgress progress: CGFloat) {
        scrollTo(offset: offset)
        XCTAssertTrue(scrollOffsetProgressController.progress.almostEqual(to: offsetProgressFromDelegate))
        XCTAssertTrue(scrollOffsetProgressController.progress.almostEqual(to: progress))
    }

    private func scrollTo(offset: CGFloat) {
        scrollOffsetProgressController.scrollOffsetAxis == .vertical ? scrollVerticalTo(offset: offset) : scrollHorizontalTo(offset: offset)
    }

    private func scrollVerticalTo(offset: CGFloat) {
        scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
    }

    private func scrollHorizontalTo(offset: CGFloat) {
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
    }
}

extension KOScrollOffsetProgressControllerTests: KOScrollOffsetProgressControllerDelegate {
    public func scrollOffsetProgressController(_ scrollOffsetProgressController: KOScrollOffsetProgressController, offsetProgress: CGFloat) {
        offsetProgressFromDelegate = offsetProgress
        XCTAssertEqual(self.scrollOffsetProgressController, scrollOffsetProgressController)
    }
}
