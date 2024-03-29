#import "UIColor+Mixing.h"
@implementation UIColor (Mixing)
+ (UIColor*)rybColorWithRed:(CGFloat)red yellow:(CGFloat)yellow blue:(CGFloat)blue alpha:(CGFloat)alpha {
    float r, y, b, g, w, my, mg, n;
    r = red;
    y = yellow;
    b = blue;
    w = MIN(r, MIN(y,b));
    r -= w;
    y -= w;
    b -= w;
    my = MAX(r, MAX(y,b));
    g = MIN(y, b);
    y -= g;
    b -= g;
    if (b && g) {
        b *= 2.0;
        g *= 2.0;
    }
    r += y;
    g += y;
    mg = MAX(r, MAX(g, b));
    if (mg) {
        n = my / mg;
        r *= n;
        g *= n;
        b *= n;
    }
    r += w;
    g += w;
    b += w;
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}
- (void)rybGetRed:(CGFloat*)red yellow:(CGFloat*)yellow blue:(CGFloat*)blue alpha:(CGFloat*)alpha {
    CGFloat r, g, b, w, y, mg, my, n, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    w = MIN(r, MIN(g,b));
    r -= w;
    g -= w;
    b -= w;
    mg = MAX(r, MAX(g,b));
    y = MIN(r,g);
    r -= y;
    g -= y;
    if (b && g) {
        b /= 2.0;
        g /= 2.0;
    }
    y += g;
    b += g;
    my = MAX(r, MAX(y, b));
    if (my) {
        n = mg / my;
        r *= n;
        y *= n;
        b *= n;
    }
    r += w;
    y += w;
    b += w;
    if (red) *red = r;
    if (yellow) *yellow = y;
    if (blue) *blue = b;
    if (alpha) *alpha = a;
    NSLog(@"rybGetRed, ending values are %f, %f, %f, %f.",*red, *yellow, *blue, *alpha);
}
+ (UIColor*)cmykColorWithCyan:(CGFloat)cyan magenta:(CGFloat)magenta yellow:(CGFloat)yellow black:(CGFloat)black alpha:(CGFloat)alpha {
    float r, g, b, c, m, y, k;
    c = cyan;
    m = magenta;
    y = yellow;
    k = black;
    r = (1-k)-(1-k)*c;
    g = (1-k)-(1-k)*m;
    b = (1-k)-(1-k)*y;
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}
- (void)cmykGetCyan:(CGFloat *)cyan magenta:(CGFloat *)magenta yellow:(CGFloat *)yellow black:(CGFloat *)black alpha:(CGFloat *)alpha {
    float r, g, b, c, m, y, k, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    k = MIN(1-r, MIN(1-g, 1-b));
    if (k < 1) {
        c = (1-r-k)/(1-k);
        m = (1-g-k)/(1-k);
        y = (1-b-k)/(1-k); 
    }
    else {
        c = 0;
        m = 0;
        y = 0;
    }
    if (cyan) *cyan = c;
    if (magenta) *magenta = m;
    if (yellow) *yellow = y;
    if (black) *black = k;
    if (alpha) *alpha = a;
}
+ (UIColor*)rgbMixForColors:(NSArray*)arrayOfColors {
    UIColor *resultColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    CGFloat c1, c2, c3, c1Total, c2Total, c3Total, notUsed; 
    int count = [arrayOfColors count];
    if (count == 0) return resultColor;
    if (count == 1) return [[arrayOfColors lastObject] copy];
    c1Total = c2Total = c3Total = 0;
    for (UIColor* aColor in arrayOfColors) {
        [aColor getRed:&c1 green:&c2 blue:&c3 alpha:&notUsed];
        c1Total += c1;
        c2Total += c2;
        c3Total += c3;
    }    
    c1 = c1Total/sqrt((sqrt(count))); 
    c2 = c2Total/sqrt((sqrt(count)));
    c3 = c3Total/sqrt((sqrt(count)));
    resultColor = [UIColor colorWithRed:c1 green:c2 blue:c3 alpha:1.0];        
    return resultColor;
}
+ (UIColor*)rybMixForColors:(NSArray*)arrayOfColors {
    CGFloat c1, c2, c3, c1Total, c2Total, c3Total, notUsed; 
    int count = [arrayOfColors count];
    float br;
    if (count == 0) return [UIColor blackColor];
    if (count == 1) return [[arrayOfColors lastObject] copy];
    c1Total = c2Total = c3Total = 0;
    for (UIColor* aColor in arrayOfColors) {
        [aColor rybGetRed:&c1 yellow:&c2 blue:&c3 alpha:&notUsed];
        c1Total += c1;
        c2Total += c2;
        c3Total += c3;
    }    
    br = c1Total/count;
    c1 = c1Total/sqrt((sqrt(count-br))); 
    br = c2Total/count;
    c2 = c2Total/sqrt((sqrt(count-br)));
    br = c2Total/count;
    c3 = c3Total/sqrt((sqrt(count-br)));
    return [UIColor rybColorWithRed:c1 yellow:c2 blue:c3 alpha:1.0];
}
+ (UIColor*)cmykMixForColors:(NSArray*)arrayOfColors {
    CGFloat c1, c2, c3, c4, m1, m2, m3, m4, c1Total, c2Total, c3Total, c4Total, notUsed;
    int count = [arrayOfColors count];
    if (count == 0) return  [UIColor whiteColor];;
    if (count == 1) return  [[arrayOfColors lastObject] copy];
    m1 = m2 = m3 = m4 = 0;
    c1Total = c2Total = c3Total = c4Total = 0;
    for (UIColor* aColor in arrayOfColors) {
        [aColor cmykGetCyan:&c1 magenta:&c2 yellow:&c3 black:&c4 alpha:&notUsed];
        c1Total += c1;
        c2Total += c2;
        c3Total += c3;
        c4Total += c4;
        m1 = (c1 > m1 ? c1 : m1);
        m2 = (c2 > m2 ? c2 : m2);
        m3 = (c3 > m3 ? c3 : m3);
        m4 = (c4 > m4 ? c4 : m4);        
    }    
    c1 = c1Total/sqrt(count+1);
    c2 = c2Total/sqrt(count+1);
    c3 = c3Total/sqrt(count+1);
    c4 = c4Total/sqrt(sqrt(count));
    return [UIColor cmykColorWithCyan:c1 magenta:c2 yellow:c3 black:c4 alpha:1.0];
}
@end
