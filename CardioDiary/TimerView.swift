//
//  TimerView.swift
//  CardioDiary
//
//  Created by Kristen Splonskowski on 3/13/17.
//  Copyright © 2017 Kristen Splonskowski. All rights reserved.
//

import UIKit

class TimerView: UIView {

	public var percentage: CGFloat = 0 {
		didSet {
			setNeedsDisplay()
		}
	}
	
	public var color: UIColor = UIColor(red: 99.0/255.0, green: 118.0/255.0, blue: 141.0/255.0, alpha: 1.0) {
		didSet {
			setNeedsDisplay()
		}
	}

    override func draw(_ rect: CGRect) {
		
		let circlePath = UIBezierPath(ovalIn: bounds.insetBy(dx: 1, dy: 1))
		UIColor.white.set()
		circlePath.fill()
		
		let arcOffset = CGFloat.pi/2
		let center = CGPoint(x: bounds.size.width/2, y: bounds.size.height/2)
		let radius = bounds.size.width/2-1
		
		let arcPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0-arcOffset, endAngle: percentage*2.0*CGFloat.pi-arcOffset, clockwise: true)
		arcPath.addLine(to: center)

		color.set()
		arcPath.fill()
		circlePath.stroke()
    }

}
