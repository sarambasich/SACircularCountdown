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

/// Mmmmm, pi...
private let π = CGFloat(M_PI)

/**
    Circular-wedge shaped countdown widget.
 
    Draws circle with radius `circleRadius` and color `circleColor`. 
    If `circleStrokeColor`, draws stroke with width of `circleStrokeWidth`. Circle
    wedge starts at 0.0 and ends at `angle`. The `interval` determines
    how long the circle counts down for. The interval is based on `baseDate`,
    or the current date.
*/
@IBDesignable
public class CircularCountdown: UIView {
    /// What color to fill the progress circle
    @IBInspectable var circleColor: UIColor?
    /// Size of the circle's radius `r`. Frame size will be the diameter `d` where `d = 2r`.
    @IBInspectable var circleRadius: CGFloat = 0.0
    /// Optional stroke color for the progress circle
    @IBInspectable var circleStrokeColor: UIColor?
    /// Defaults to 0.0 (no stroke)
    @IBInspectable var circleStrokeWidth: CGFloat = 0.0
    /// The angle to set the indicator's progress at (you probably won't touch this 98% of the time)
    @IBInspectable var angle: CGFloat = 0.0
    /// Length of cycle represented by this indicator
    @IBInspectable var interval: CGFloat = 30.0
    
    /// Base date to calculate timer's interval; optional and defaults to
    /// `NSDate()` when needed
    var baseDate: NSDate?
    
    /// Display link
    private var displayLink: CADisplayLink?
    /// The progress circle's path
    private let circlePath = UIBezierPath()
    /// The progress circle's shape layer
    private let circleLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        drawCircleLayer(angle)
    }
    
    /**
        Set up the countdown.
    */
    private func initialize() {
        configureDisplayLink()
    }
    
    /**
        Removes old layers. Fills in the circle layer with stroke and fill colors.
     
         - parameter angle: Angle in degrees.
         - parameter clockwise: Whether the angle is drawn clockwise. default=true
     */
    private func drawCircleLayer(angle: CGFloat, clockwise: Bool = true) {
        if let ls = layer.sublayers {
            for l in ls {
                l.removeFromSuperlayer()
            }
        }
        
        circleLayer.path = drawCirclePath(angle)
        circleLayer.fillColor = circleColor?.CGColor
        circleLayer.strokeColor = circleStrokeColor?.CGColor
        circleLayer.lineWidth = circleStrokeWidth
        
        layer.addSublayer(circleLayer)
    }
    
    /**
        Draws the path for the circle wedge we want to display.
        
        - parameter angle: The angle to draw the circle (wedge) until in degrees.
    */
    private func drawCirclePath(angle: CGFloat) -> CGPath {
        let center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        circlePath.removeAllPoints()
        circlePath.addArcWithCenter(center, radius: circleRadius, startAngle: 3.0*π/2.0, endAngle: angle.radians, clockwise: false)
        circlePath.addLineToPoint(center)
        circlePath.closePath()
        return circlePath.CGPath
    }
    
    /**
        `CADisplayLink` support
    */
    private func configureDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: "update:")
        displayLink?.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    /**
        Releases `CADisplayLink` resources.
    */
    private func cleanUpDisplayLink() {
        displayLink?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        displayLink = nil
    }
    
    /**
        Callback for `CADisplayLink` to calculate time interval for countdonw.
     
        - parameter displayLink: The display link object.
    */
    @objc func update(displayLink: CADisplayLink) {
        let ofInterval: NSTimeInterval = fabs(((self.baseDate ?? NSDate()).timeIntervalSince1970) % NSTimeInterval(self.interval))
        let progress = CGFloat(ofInterval) / CGFloat(self.interval)
        self.drawCircleLayer(360.0 * progress)
    }
}


private extension CGFloat {
    /// Converts the receiver, assumed to be in degrees, to radians.
    private var radians: CGFloat {
        return self * CGFloat(M_PI) / 180.0
    }
}

