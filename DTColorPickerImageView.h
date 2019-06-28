#import <UIKit/UIKit.h>
typedef void(^DTColorPickerHandler)(UIColor *__nonnull color);
@protocol DTColorPickerImageViewDelegate;
NS_ASSUME_NONNULL_BEGIN
@interface DTColorPickerImageView : UIImageView
@property (assign, nullable) IBOutlet id<DTColorPickerImageViewDelegate> delegate;
+ (instancetype)colorPickerWithFrame:(CGRect)frame;
+ (instancetype)colorPickerWithImage:(nullable UIImage *)image;
- (void)handlesDidPickColor:(DTColorPickerHandler)handler;
@end
@protocol DTColorPickerImageViewDelegate <NSObject>
@optional
- (void)imageView:(DTColorPickerImageView *)imageView didPickColorWithColor:(UIColor *)color;
@end
NS_ASSUME_NONNULL_END