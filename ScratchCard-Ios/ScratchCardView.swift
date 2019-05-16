//
//  ScratchCardView.swift
//  ScratchCard-Ios
//
//  Created by PranayBansal on 01/05/19.
//  Copyright © 2019 PranayBansal. All rights reserved.
//

import UIKit

@IBDesignable class ScratchCardView: UIView {
    
    @IBInspectable var ivInputOverlay: UIImage?
    
    private var ivOverlay: UIImage!
    private var isSwiped = false
    private var startPoint: CGPoint!
    private var context:CGContext!
    private var delegate:ScratchCardListener!
    
    private var isResetting: Bool = false

    
    var coordinates = [(startPoint:CGPoint,endPoint:CGPoint)]()
    
    struct Constants {
        let screatchThreshold = 0.4
    }

    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    
        let inputOverlayImage = ivInputOverlay
        
        ivOverlay = inputOverlayImage
        
        if ivOverlay != nil {
            
            ivOverlay.draw(in: rect)
            
            context = UIGraphicsGetCurrentContext()
            
            for each in coordinates {
                self.drawLineFrom(fromPoint:each.startPoint , toPoint: each.endPoint)
            }
            
            if calculateArea() > 0.4{
                if coordinates.count > 1{
                    reset()
                    delegate?.scratchFinished()
                }
            }
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        isSwiped = false
        self.startPoint = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(!isSwiped){
            coordinates.append((startPoint,startPoint))
            setNeedsDisplay()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        isSwiped = true

        let currentPoint = touch.location(in: self)
        coordinates.append((startPoint,currentPoint))
        self.startPoint = currentPoint

        setNeedsDisplay()
    }
    
    private func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        context.setLineWidth(50)
        context.move(to: fromPoint)
        context.setBlendMode(.clear)
        context.setLineCap(.round)
        context.addLine(to: toPoint)
        context.strokePath()
        
    }
    
    private func reset(){
        //ivOverlay = nil
        //ivInputOverlay = nil
        
        guard !isResetting else { return }
        
        print("animating")
        isResetting = true
        UIView.animate(withDuration: 2, delay: 1, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 0
        }, completion: { finished in
            self.isHidden = true
            self.isResetting = false
        })
    }
    
    private func calculateArea() -> Double{
        
        guard let image = getSnapshot(), let imageData = image.dataProvider?.data else {
            return 0.0
        }
        
        let width = image.width
        let height = image.height
        let imageDataPointer: UnsafePointer<UInt8> = CFDataGetBytePtr(imageData)
        var transparentPixelCount = 0
        
        for x in 0...width {
            for y in 0...height {
                let pixelDataPosition = ((width * y) + x) * 4
                // The alpha value is the last 8 bits of the data
                let alphaValue = imageDataPointer[pixelDataPosition + 3]
                if alphaValue == 0 {
                    transparentPixelCount += 1
                }
            }
        }
        
        var transparentPercent = Double(transparentPixelCount) / Double((width * height))
        transparentPercent = max(transparentPercent, 0)
        transparentPercent = min(transparentPercent, 1)
        print(transparentPercent)
        return transparentPercent
    }
    
    func getSnapshot() -> CGImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        layer.render(in: ctx)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.cgImage
    }
    
}

protocol ScratchCardListener {
    func scratchFinished()
}
