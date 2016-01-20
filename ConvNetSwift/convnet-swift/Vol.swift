// Vol is the basic building block of all data in a net.
// it is essentially just a 3D volume of numbers, with a
// width (sx), height (sy), and depth (depth).
// it is used to hold data for all filters, all volumes,
// all weights, and also stores all gradients w.r.t.
// the data. c is optionally a value to initialize the volume
// with. If c is missing, fills the Vol with random numbers.

import Foundation

class Vol {
    var sx: Int = 1
    var sy: Int = 1
    var depth: Int = 0
    var w: [Double] = []
    var dw: [Double] = []
    
    convenience init (array: [Double]) {
        self.init()

        // we were given a list in sx, assume 1D volume and fill it up
        self.sx = 1
        self.sy = 1
        self.depth = array.count
        // we have to do the following copy because we want to use
        // fast typed arrays, not an ordinary javascript array
        self.w = zerosDouble(self.depth)
        self.dw = zerosDouble(self.depth)
        for i in 0 ..< self.depth {
            self.w[i] = array[i]
        }
    }
    
    convenience init(width sx: Int, height sy: Int, depth: Int, array: [Double]) {
        self.init()
        assert(array.count==sx*sy*depth)
        self.sx = sx
        self.sy = sy
        self.depth = depth
        self.w = array
    }
    
    convenience init(sx: Int, sy: Int, depth: Int) {
        self.init(width: sx, height: sy, depth: depth, c: nil)
    }
    
    convenience init(sx: Int, sy: Int, depth: Int, c: Double) {
        self.init(width: sx, height: sy, depth: depth, c: c)
    }
    
    convenience init(width sx: Int, height sy: Int, depth: Int, c: Double?) {
        self.init()
        // we were given dimensions of the vol
        self.sx = sx
        self.sy = sy
        self.depth = depth
        let n = sx*sy*depth
        self.w = zerosDouble(n)
        self.dw = zerosDouble(n)
        if c == nil {
            // weight normalization is done to equalize the output
            // variance of every neuron, otherwise neurons with a lot
            // of incoming connections have outputs of larger variance
            let scale = sqrt(1.0/Double(sx*sy*depth))
            for i in 0 ..< n {

                self.w[i] = RandUtils.randn(0.0, std: scale)
            }
        } else {
            for i in 0 ..< n {

                self.w[i] = c!
            }
        }
        
    }
    
    func get(x x: Int, y: Int, d: Int) -> Double {
        let ix=((self.sx * y)+x)*self.depth+d
        return self.w[ix]
    }
    
    func set(x x: Int, y: Int, d: Int, v: Double) -> () {
        let ix=((self.sx * y)+x)*self.depth+d
        self.w[ix] = v
    }
    
    func add(x x: Int, y: Int, d: Int, v: Double) -> () {
        let ix=((self.sx * y)+x)*self.depth+d
        self.w[ix] += v
    }
    
    func getGrad(x x: Int, y: Int, d: Int) -> Double {
        let ix = ((self.sx * y)+x)*self.depth+d
        return self.dw[ix]
    }
    
    func setGrad(x x: Int, y: Int, d: Int, v: Double) -> () {
        let ix = ((self.sx * y)+x)*self.depth+d
        self.dw[ix] = v
    }
    
    func addGrad(x x: Int, y: Int, d: Int, v: Double) -> () {
        let ix = ((self.sx * y)+x)*self.depth+d
        self.dw[ix] += v
    }
    
    func cloneAndZero() -> Vol {
        return Vol(sx: self.sx, sy: self.sy, depth: self.depth, c: 0.0)
    }
    
    func clone() -> Vol {
        let V = Vol(sx: self.sx, sy: self.sy, depth: self.depth, c: 0.0)
        let n = self.w.count
        for i in 0 ..< n {
            V.w[i] = self.w[i]
        }
        return V
    }
    
    func addFrom(V: Vol) {
        for k in 0 ..< self.w.count {
            self.w[k] += V.w[k]
        }
    }
    
    func addFromScaled(V: Vol, a: Double) {
        for k in 0 ..< self.w.count {
            self.w[k] += a*V.w[k]
        }
    }
    
    func setConst(a: Double) {
        for var k=0; k<self.w.count; k++ {
            self.w[k] = a
        }
    }
    
    func toJSON() -> [String: AnyObject] {
        // TODO: we may want to only save d most significant digits to save space
        var json: [String: AnyObject] = [:]
        json["sx"] = self.sx
        json["sy"] = self.sy
        json["depth"] = self.depth
        json["w"] = self.w
        return json
        // we wont back up gradients to save space
    }

//    func fromJSON(json: [String: AnyObject]) -> () {
//        self.sx = json["sx"]
//        self.sy = json["sy"]
//        self.depth = json["depth"]
//        
//        var n = self.sx*self.sy*self.depth
//        self.w = zeros(n)
//        self.dw = zeros(n)
//        // copy over the elements.
//        for i in 0 ..< n {
//
//            self.w[i] = json["w"][i]
//        }
//    }
    
    func description() -> String {
        return "size: \(sx)*\(sy)*\(depth)\nw:\n\(w)\ndw:\n\(dw)"
    }
    
    func debugDescription() -> String {
        return "size: \(sx)*\(sy)*\(depth)\nw:\n\(w)\ndw:\n\(dw)"
    }
}
