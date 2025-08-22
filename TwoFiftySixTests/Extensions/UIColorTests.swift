@testable import TwoFiftySix
import UIKit
import Testing

struct UIColorTests {
    @Test("Int initializer gives correct values")
    func intInitializer() {
        do {
            let result = UIColor(red: 255, green: 255, blue: 255)
            var red = CGFloat.zero
            var green = CGFloat.zero
            var blue = CGFloat.zero
            var alpha = CGFloat.zero
            result.getRed(&red, green: &blue, blue: &green, alpha: &alpha)
            #expect(red == 1)
            #expect(green == 1)
            #expect(blue == 1)
            #expect(alpha == 1)
        }
        do {
            let result = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            var red = CGFloat.zero
            var green = CGFloat.zero
            var blue = CGFloat.zero
            var alpha = CGFloat.zero
            result.getRed(&red, green: &blue, blue: &green, alpha: &alpha)
            #expect(red == 0)
            #expect(green == 0)
            #expect(blue == 0)
            #expect(alpha == 0)
        }
        do {
            let result = UIColor(red: 127, green: 127, blue: 127)
            var red = CGFloat.zero
            var green = CGFloat.zero
            var blue = CGFloat.zero
            var alpha = CGFloat.zero
            result.getRed(&red, green: &blue, blue: &green, alpha: &alpha)
            #expect(red == 0.4980392156862745)
            #expect(green == 0.4980392156862745)
            #expect(blue == 0.4980392156862745)
            #expect(alpha == 1)
        }
    }
    @Test("Hex initializer gives correct values")
    func hexInitializer() {
        do {
            let result = UIColor(rgb: 0xffffff)
            var red = CGFloat.zero
            var green = CGFloat.zero
            var blue = CGFloat.zero
            var alpha = CGFloat.zero
            result.getRed(&red, green: &blue, blue: &green, alpha: &alpha)
            #expect(red == 1)
            #expect(green == 1)
            #expect(blue == 1)
            #expect(alpha == 1)
        }
        do {
            let result = UIColor(rgb: 0x000000, alpha: 0)
            var red = CGFloat.zero
            var green = CGFloat.zero
            var blue = CGFloat.zero
            var alpha = CGFloat.zero
            result.getRed(&red, green: &blue, blue: &green, alpha: &alpha)
            #expect(red == 0)
            #expect(green == 0)
            #expect(blue == 0)
            #expect(alpha == 0)
        }
        do {
            let result = UIColor(rgb: 0x7f7f7f)
            var red = CGFloat.zero
            var green = CGFloat.zero
            var blue = CGFloat.zero
            var alpha = CGFloat.zero
            result.getRed(&red, green: &blue, blue: &green, alpha: &alpha)
            #expect(red == 0.4980392156862745)
            #expect(green == 0.4980392156862745)
            #expect(blue == 0.4980392156862745)
            #expect(alpha == 1)
        }
    }

}
