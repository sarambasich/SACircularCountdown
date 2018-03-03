//
//  SACircularCountdown.swift
//  SACircularCountdown
//
//  Created by Stefan Arambasich on 12/26/2015.
//
//  Copyright (c) 2015-2016 Stefan Arambasich. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

/// The mathematical constant pi.
private let π = Double.pi


/// Circular-wedge shaped countdown widget.
///
/// Draws circle with radius `circleRadius` and color `circleColor`.
/// If `strokeColor`, draws stroke with width of `strokeWidth`. Circle
/// wedge starts at 0.0 and ends at `angle`. The `interval` determines
/// how long the circle counts down for. The interval is based on `baseDate`,
/// the current date by default.
@IBDesignable public class CircularCountdown: UIView {

    /// What color to fill the progress circle.
    @IBInspectable var circleColor: UIColor?

    /// Size of the circle's radius `r`. Frame size will be the diameter `d` where `d = 2r`.
    @IBInspectable var circleRadius: CGFloat = 0.0

    /// Optional stroke color for the progress circle.
    @IBInspectable var strokeColor: UIColor?

    /// Defaults to 0.0 (no stroke).
    @IBInspectable var strokeWidth: CGFloat = 0.0

    /// The angle in degrees to set the indicator's progress at.
    @IBInspectable var angle: CGFloat = 0.0

    /// Length of cycle represented by this indicator.
    @IBInspectable var interval: CGFloat = 30.0
    
    /// Base date to calculate timer's interval; optional and defaults to
    /// `Date()` when needed.
    var baseDate: Date?
    
    /// Display link
    private var displayLink: CADisplayLink?

    /// The progress circle's path
    private let circlePath = UIBezierPath()

    /// The progress circle's shape layer
    private let circleLayer = CAShapeLayer()

    // MARK: - Initialization

    init(displayLink: CADisplayLink) {
        self.displayLink = displayLink

        super.init(frame: .zero)

        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }

    // MARK: Public methods
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)

        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(update(displayLink:)))
            startDisplayLink()
        }
        drawCircleLayer(angle: angle)
    }

    /// Set up the countdown.
    private func initialize() {

    }

    /// Removes old layers. Fills in the circle layer with stroke and fill colors.
    ///
    /// - Parameters:
    ///   - angle: Angle in degrees.
    ///   - clockwise: Whether the angle is drawn clockwise. default=true
    private func drawCircleLayer(angle: CGFloat, clockwise: Bool = true) {
        if let ls = layer.sublayers {
            for l in ls {
                l.removeFromSuperlayer()
            }
        }
        
        circleLayer.path = drawCirclePath(angle: angle)
        circleLayer.fillColor = circleColor?.cgColor
        circleLayer.strokeColor = strokeColor?.cgColor
        circleLayer.lineWidth = strokeWidth
        
        layer.addSublayer(circleLayer)
    }

    /// Draws the path for the circle wedge we want to display.
    ///
    /// - Parameter angle: The angle to draw the circle (wedge) until in degrees.
    /// - Returns: The path itself.
    private func drawCirclePath(angle: CGFloat) -> CGPath {
        let center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        circlePath.removeAllPoints()
        circlePath.addArc(withCenter: center,
                          radius: circleRadius,
                          startAngle: CGFloat(3.0 * π/2.0),
                          endAngle: angle.radians,
                          clockwise: false)
        circlePath.addLine(to: center)
        circlePath.close()
        return circlePath.cgPath
    }
    
    // MARK: - `CADisplayLink` support

    /// Add the display link to the current run loop.
    private func startDisplayLink() {
        displayLink?.add(to: .current, forMode: .defaultRunLoopMode)
    }

    /// Removes from the run loop and releases `CADisplayLink`.
    private func cleanUpDisplayLink() {
        displayLink?.remove(from: .current, forMode: .defaultRunLoopMode)
        displayLink = nil
    }

    /// Callback for `CADisplayLink` to calculate time interval for countdonw.
    ///
    /// - Parameter displayLink: The display link object.
    @objc func update(displayLink: CADisplayLink) {
        guard displayLink === self.displayLink else { return }

        let unicodeTimestamp = (baseDate ?? Date()).timeIntervalSince1970
        let ofInterval = TimeInterval(
            fabs(
                unicodeTimestamp
                    .truncatingRemainder(dividingBy: TimeInterval(interval))
            )
        )
        let progress = CGFloat(ofInterval) / CGFloat(interval)
        drawCircleLayer(angle: 360.0 * progress)
    }
}


private extension CGFloat {

    /// Converts the receiver, assumed to be in degrees, to radians.
    var radians: CGFloat {
        return self * CGFloat(π) / 180.0
    }
}

