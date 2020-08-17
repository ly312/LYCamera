#import "LYCamera.h"
#import <AVFoundation/AVFoundation.h>

@interface LYCamera ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) UIViewController *view;

@end

@implementation LYCamera

+(LYCamera *)shareInit{
    
    static LYCamera *data = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = [[LYCamera alloc] init];
    });
    return data;
    
}

-(void)openWithView:(UIViewController *)view Block:(LYCameraBlock)block{
    
    _view = view;
    _LYCameraBlock = block;
    
    NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
//        [[[EGCAlertController alloc]init] showWithController:_view Message:@"EGC_TURNED_ON_CAMERA" Confirm:^{
//            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//            [[UIApplication sharedApplication] openURL:url];
//        }];
        
    }else{
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"EGC_CANCEL"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"EGC_PHOTOGRAPH",@"EGC_ALBUM",nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showInView:_view.view];
        
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            NSLog(@"失败");
        }else{
            UIImagePickerController * imagePicker = [[UIImagePickerController alloc]init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;//设置源类型
//            [imagePicker setEditing:YES animated:YES];//允许编辑
//            imagePicker.allowsEditing = YES;
            imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
            [_view presentViewController:imagePicker animated:YES completion:nil];
        }
        
    }else if (buttonIndex == 1){
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            UIImagePickerController * imagePicker = [[UIImagePickerController alloc]init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//设置源类型
//            [imagePicker setEditing:YES animated:YES];//允许编辑
//            imagePicker.allowsEditing = YES;
            imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
            [_view presentViewController:imagePicker animated:YES completion:nil];
        }
        
    }
    
}

//打开相册之后选择的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString * mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    __weak typeof(self) wSelf = self;
    if ([mediaType hasSuffix:@"image"]){
//        UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];//允许编辑
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
        //返回的就是jpeg格式的data
        //压缩图片
        UIImage *img = [self scaleImage:image sclae:0.3 ratio:0.3];
        NSData *dataImage = UIImageJPEGRepresentation(img, 0.5);
        
        if (picker.sourceType != UIImagePickerControllerSourceTypePhotoLibrary) {
            //把图片保存到相册
            [self saveImageToPhotos:image];
        }
        
        [_view dismissViewControllerAnimated:YES completion:^{
            if (wSelf.LYCameraBlock) {
                wSelf.LYCameraBlock(dataImage);
            }
        }];
        
    }
    
}

//实现该方法
- (void)saveImageToPhotos:(UIImage*)savedImage{
    //因为需要知道该操作的完成情况，即保存成功与否，所以此处需要一个回调方法image:didFinishSavingWithError:contextInfo:
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

//回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    NSString *msg = nil;
    if(error != NULL){
        msg = @"EGC_SAVE_FAILURE";
    }else{
        msg = @"EGC_SAVE_SUCCESS";
    }
    NSLog(@"msg = %@",msg);
    
}

#pragma mark - 压缩图片
-(UIImage *)scaleImage:(UIImage *)image sclae:(CGFloat)scale ratio:(CGFloat)ratio{
    //确定压缩后的size
    CGFloat scaleWidth = image.size.width * scale;
    CGFloat scaleHeight = image.size.height * scale;
    CGSize scaleSize = CGSizeMake(scaleWidth, scaleHeight);
    //开启图形上下文
    UIGraphicsBeginImageContext(scaleSize);
    //绘制图片
    [image drawInRect:CGRectMake(0, 0, scaleWidth, scaleHeight)];
    //从图形上下文获取图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //压缩图片
    NSData *d = UIImageJPEGRepresentation(newImage, ratio);
    //重新data转回image
    UIImage *endImage = [UIImage imageWithData:d];
    //关闭图形上下文
    UIGraphicsEndImageContext();
    return endImage;
}

@end
