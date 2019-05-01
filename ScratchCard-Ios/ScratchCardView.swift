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

    
    var coordinates = [(startPoint:CGPoint,endPoint:CGPoint)]()

    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    
        guard let inputOverlayImage = ivInputOverlay else{
            fatalError("Please Provide Overlay Image")
        }
        
        ivOverlay = inputOverlayImage
        ivOverlay.draw(in: rect)
        
        context = UIGraphicsGetCurrentContext()
        
        for each in coordinates {
            self.drawLineFrom(fromPoint:each.startPoint , toPoint: each.endPoint)
        }
        
        print(calculateArea())
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
    
    private func calculateArea() -> Double{
//        final int stepCount = (int) (scratchBitmap.getWidth() * 0.05);
        let stepcount = ivOverlay.size.width * 0.05
        
        let widthInPixels = ivOverlay.size.width * UIScreen.main.scale
        let heightInPixels = ivOverlay.size.height * UIScreen.main.scale
        let totalPixels = Double(widthInPixels * heightInPixels)
        var transparentPixels = 0.0
        for i in stride(from: 0, to: ivOverlay.size.width, by: stepcount){
            for j in stride(from: 0, to: ivOverlay.size.height, by: stepcount){
                if(ivOverlay.getPixelColor(pos: CGPoint(x: i,y: j)).alpha()==0){
                    transparentPixels+=1
                    print("transparentPixels ---> \(transparentPixels)")
                }
            }
        }
        
        return Double((stepcount*stepcount))*transparentPixels/totalPixels
    }
    
    private func reset(){
        ivOverlay = nil
        ivInputOverlay = nil
    }
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x))
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        print("color ---> \(UIColor(red: r, green: g, blue: b, alpha: a))")
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
}

extension UIColor {
    
    func alpha() -> Int {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iAlpha = Int(fAlpha * 255.0)
            print("alpha ---> \(iAlpha)")
            return iAlpha
        } else {
            return 0
        }
    }
}


