//
//  ViewController.m
//  VideoRecording
//
//  Created by 王力 on 15/10/26.
//  Copyright (c) 2015年 王力. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

//是否录制 1录视频 0拍照
@property (nonatomic, assign) BOOL isVideo;
//imagePicker
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *photo;//照片展示
//player 视频播放器
@property (nonatomic, strong) AVPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _isVideo = 1;
}

#pragma mark - UI
//拍照
- (IBAction)takeClick:(UIButton *)sender {
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        UIImage *image;
        //如果允许编辑获取编辑后的的照片, 否则获取元原始照片
        if (self.imagePicker.allowsEditing == YES) {
            image = [info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的图片
        } else {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        }
        [self.photo setImage:image];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相册
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {//如果录制视频
        NSLog(@"video...");
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *strUrl = [url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(strUrl)) {
            //保存视频到相册, 注意也可以是哟来那个ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(strUrl, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"取消");
}

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;//设置imagePicker的来源, 这里设置摄像头
        _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;//使用后置摄像头
        if (self.isVideo) {
            _imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
            _imagePicker.videoQuality = UIImagePickerControllerQualityType640x480;
            _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;//设置摄像头模式(拍照, 录制视频)
        } else {
            _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        }
        _imagePicker.allowsEditing = YES;//允许编辑
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}
//视频保存后回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"搜谱保存过程中发生错误, 错误信息:%@", error.localizedDescription);
    } else {
        NSLog(@"保存成功");
        NSURL *url = [NSURL fileURLWithPath:videoPath];
        _player = [AVPlayer playerWithURL:url];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.frame = self.photo.frame;
        [self.photo.layer addSublayer:playerLayer];
        [_player play];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end





































