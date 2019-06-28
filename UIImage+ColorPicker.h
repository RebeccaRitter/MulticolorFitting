#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface UIImage (ColorPicker)
- (UIColor *)pickColorWithPoint:(CGPoint)point;
- (CGPoint)convertPoint:(CGPoint)viewPoint fromImageView:(__kindof UIImageView *)imageView;
@end
NS_ASSUME_NONNULL_END