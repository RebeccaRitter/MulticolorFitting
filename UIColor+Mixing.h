#import <UIKit/UIKit.h>
@interface UIColor (Mixing)
+ (UIColor*)rybColorWithRed:(CGFloat)red
                     yellow:(CGFloat)yellow 
                       blue:(CGFloat)blue 
                      alpha:(CGFloat)alpha;
+ (UIColor*)cmykColorWithCyan:(CGFloat)cyan 
                      magenta:(CGFloat)magenta 
                       yellow:(CGFloat)yellow 
                        black:(CGFloat)black 
                        alpha:(CGFloat)alpha;
- (void)rybGetRed:(CGFloat*)red 
           yellow:(CGFloat*)yellow 
             blue:(CGFloat*)blue 
            alpha:(CGFloat*)alpha;
- (void)cmykGetCyan:(CGFloat*)cyan 
            magenta:(CGFloat*)magenta 
             yellow:(CGFloat*)yellow 
              black:(CGFloat*)black
              alpha:(CGFloat*)alpha;
+ (UIColor*)rgbMixForColors:(NSArray*)arrayOfColors; 
+ (UIColor*)rybMixForColors:(NSArray*)arrayOfColors; 
+ (UIColor*)cmykMixForColors:(NSArray*)arrayOfColors;
@end
