# LYCamera

```ruby

#import "LYUploadImgView.h"
LYUploadImgView *upImg = [[LYUploadImgView alloc]initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 100)];
[self.view addSubview:upImg];

#import "LYCamera.h"
[[LYCamera shareInit] openWithView:self Block:^(NSData * _Nonnull data) {
    NSLog(@"data = %@",data);
}];

```
