#import <UIKit/UIKit.h>

typedef void (^ LYUploadImgViewBlock)(NSMutableArray *imgDataSource);

@interface LYUploadImgView : UIView

@property (nonatomic, copy) LYUploadImgViewBlock block;

@property (nonatomic) NSInteger maxCount;

@end
