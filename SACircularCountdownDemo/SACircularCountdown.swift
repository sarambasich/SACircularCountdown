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

private let π = CGFloat(M_PI)

/**
    Circular-wedge shaped countdown widget. `IBDesignable` compatible.
 
    Draws circle with radius `circleRadius` and color `circleColor`. 
    If `circleStrokeColor`, draws stroke with width of `circleStrokeWidth`. Circle
    wedge starts at 0.0 and ends at `angle`. The `interval` determines
    how long the circle counts down for. The interval is based on `baseDate`,
    or the current date.
*/
@IBDesignable
open class CircularCountdown: UIView {

    /// Fill color of progress circle
    @IBInspectable var circleColor: UIColor?
    /// Size of the circle's radius `r`
    @IBInspectable var circleRadius: CGFloat = 0.0
    /// Optional stroke color for the progress circle
    @IBInspectable var circleStrokeColor: UIColor?
    /// Stroke width for indicator circle
    @IBInspectable var circleStrokeWidth: CGFloat = 0.0
    /// The angle, in radians, of the indicator's progress
    @IBInspectable var angle: CGFloat = 0.0
    /// Length of time represented by this indicator
    @IBInspectable var interval: TimeInterval = 30.0
    
    /// Display link used to synchronize drawing with display refresh
    var displayLink: CADisplayLink?

    /// The progress circle's path
    fileprivate let circlePath = UIBezierPath()
    /// The progress circle's shape layer
    fileprivate let circleLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
}

private extension CircularCountdown {
    
    /**
        Set up the countdown.
    */
    func initialize() {
        configureDisplayLink()
    }
    
    /**
        Removes old layers. Fills in the circle layer with stroke and fill colors.
     
         - parameter angle: Angle in degrees.
         - parameter clockwise: Whether the angle is drawn clockwise. default=true
     */
    func drawCircleLayer(_ angle: CGFloat, clockwise: Bool = true) {
        circleLayer.fillColor = circleColor?.cgColor
        circleLayer.strokeColor = circleStrokeColor?.cgColor
        circleLayer.lineWidth = circleStrokeWidth
        circleLayer.path = drawCirclePath(angle)

        if layer.sublayers?.filter({ $0 == circleLayer }).count ?? 0 <= 0 {
            layer.addSublayer(circleLayer)
        }
    }
    
    /**
        Draws the path for the circle wedge we want to display.
        
        - parameter angle: The angle to draw the circle (wedge) until in degrees.
    */
    func drawCirclePath(_ angle: CGFloat) -> CGPath {
        let center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        circlePath.removeAllPoints()
        circlePath.addArc(withCenter: center, radius: circleRadius, startAngle: 3.0*π/2.0,
                          endAngle: angle.radians - π/2.0, clockwise: false)
        circlePath.addLine(to: center)
        circlePath.close()
        return circlePath.cgPath
    }
    
    /**
        `CADisplayLink` support
    */
    func configureDisplayLink() {
        guard displayLink == nil else { return }
        displayLink = CADisplayLink(target: self, selector: #selector(CircularCountdown.update(_:)))
        displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    /**
        Releases `CADisplayLink` resources.
    */
    func cleanUpDisplayLink() {
        guard displayLink != nil else { return }
        displayLink?.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        displayLink = nil
    }
    
    /**
        Callback for `CADisplayLink` to calculate time interval for countdonw.
     
        - parameter displayLink: The display link object.
    */
    @objc func update(_ _: CADisplayLink) {
        let ofInterval: TimeInterval = fabs(NSDate()
            .timeIntervalSince1970.truncatingRemainder(dividingBy: TimeInterval(interval))),
        progress = CGFloat(ofInterval) / CGFloat(interval)
        drawCircleLayer(360.0 * progress)
    }
}


private extension CGFloat {

    /// Converts the receiver, assumed to be in degrees, to radians.
    var radians: CGFloat {
        return self * CGFloat(M_PI) / 180.0
    }
}

