class SupportOpposeView : UIView {
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let weight = CGFloat(Float(arc4random()) /  Float(UInt32.max))
        let support = CGFloat(Float(arc4random()) /  Float(UInt32.max))
        let oppose = 1 - support
        
        let halfWidth = bounds.width / 2
        let halfHeight = bounds.height / 2
        
        let barWidth = halfWidth * weight
        
        let supportWidth = barWidth * support
        let opposeWidth = barWidth * oppose
        
        let opposeBar = CGRect(origin: CGPoint(x: halfWidth - supportWidth, y: (bounds.height - halfHeight) / 2), size: CGSize(width: supportWidth, height: halfHeight))
        let supportBar = CGRect(origin: CGPoint(x: halfWidth, y: (bounds.height - halfHeight) / 2), size: CGSize(width: opposeWidth, height: halfHeight))
        
        let context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, Colors.orange.CGColor)
        CGContextFillRect(context, opposeBar)
        
        CGContextSetFillColorWithColor(context, Colors.green.CGColor)
        CGContextFillRect(context, supportBar)
        
        let divider = CGRect(origin: CGPoint(x: halfWidth - 1, y: 0), size: CGSize(width: 2, height: bounds.height))
        CGContextSetFillColorWithColor(context, UIColor(colorLiteralRed: 0.35, green: 0.35, blue: 0.35, alpha: 1).CGColor)
        CGContextFillRect(context, divider)
    }
}
