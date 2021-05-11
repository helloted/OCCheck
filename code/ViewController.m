//
//  ViewController.m
//  ScreenShot
//
//  Created by Haozhicao on 2021/4/19.
//

#import "ViewController.h"
#import "Person.h"
#import <AVFoundation/AVFoundation.h>
#import <TZImagePickerController.h>
#import "HTPreviewViewController.h"
#import "HTMergeManager.h"

int a_a = 0;

@interface viewController ()<TZImagePickerControllerDelegate>

@property (nonatomic, strong)JGProgressHUD *HUD;

@property (nonatomic, strong)NSMutableArray  *MYubImagesArray;

@property (nonatomic, strong)NSString      *room;

@end

@implementation viewController

- (void)ViewDidLoad {
    [super viewDidLoad];
    
    NSString *The_bac =@"abv";
    
UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
startBtn.frame = CGRectMake(100, 200, 50, 50);
[self.view addSubview:startBtn];
[self.view addSubview:startBtn];
[startBtn addTarget:self action:@selector(videoTest) forControlEvents:UIControlEventTouchUpInside];

[startBtn addTarget:self action:@selector(videoTest) forControlEvents:UIControlEventTouchUpInside];

NSLog(@"my log");

    
    
}

- (void)VideoTest{
NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"wx" ofType:@"mp4"];
[self splitViedeosToImagesWithVideoPath:moviePath];

//    [[HTMergeManager manager] mergeImagesWithCount:78 finish:^(BOOL success, NSString * _Nonnull imagePath) {
//        [self showPreViewWithImagePath:imagePath];
//    }];

//    [self showPreViewWithImagePath:kHTMergeFinishResultImagePath];
    
}




- (void)showPreViewWithImage:(UIImage *)image{
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/1.jpg",kHTVideoToImagesSaveDirectory];
    image = [UIImage imageWithContentsOfFile:imagePath];
    
    HTPreviewViewController *previewVC = [[HTPreviewViewController alloc]init];
    previewVC.fullImage = image;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:previewVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showPreViewWithImagePath:(NSString *)imagePath{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        HTPreviewViewController *previewVC = [[HTPreviewViewController alloc]init];
        previewVC.imagePath = imagePath;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:previewVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    });
}

- (void)hudIncresProgress:(NSUInteger)progress total:(NSUInteger)total{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (progress == 0) {
            [self.HUD showInView:self.view];
        }
        
        if (progress >= total) {
            self.HUD.textLabel.text = @"Success";
            self.HUD.detailTextLabel.text = nil;
            self.HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
            [self.HUD dismissAfterDelay:0.3 animated:YES completion:^{
                self.HUD = nil;
            }];
            return;
        }
        
        CGFloat floatProgress = (progress * 1.0)/total;
        NSInteger intProgress = (NSInteger)(floatProgress * 100);
        [self.HUD setProgress:floatProgress animated:NO];
        self.HUD.detailTextLabel.text = [NSString stringWithFormat:@"%lu%%", (unsigned long)intProgress];
    });
}

- (void)splitViedeosToImagesWithVideoPath:(NSString *)videoPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:kHTVideoToImagesSaveDirectory error:nil];
    if (![fileManager fileExistsAtPath:kHTVideoToImagesSaveDirectory]) {
        [fileManager createDirectoryAtPath:kHTVideoToImagesSaveDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        NSLog(@"FileImage is exists.");
    }
    [self nativeTransferMovie:videoPath toImagesDirectory:kHTVideoToImagesSaveDirectory];
}

- (void)selectVideoFromPhots{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowTakeVideo = NO;
    imagePickerVc.allowPickingImage = NO;
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *asset) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                AVURLAsset* urlAsset = (AVURLAsset*)asset;
                [self splitViedeosToImagesWithVideoPath:urlAsset.URL.absoluteString];
         }
        }];
    }];
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}


- (NSError *)nativeTransferMovie:(NSString *)movie toImagesDirectory:(NSString *)imgsDiretory
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:movie] options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    CMTime time = asset.duration;
    
    double fps_i = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] nominalFrameRate];
    int FPS = round(fps_i);
    
    NSUInteger totalFrameCount = CMTimeGetSeconds(time) * FPS;
    NSMutableArray *timesArray = [NSMutableArray arrayWithCapacity:totalFrameCount];
    for (NSUInteger ii = 0; ii < totalFrameCount; ++ii) {
        CMTime timeFrame = CMTimeMake(ii, FPS);
        NSValue *timeValue = [NSValue valueWithCMTime:timeFrame];
        [timesArray addObject:timeValue];
    }
    
    
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    __block NSError *returnError = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.HUD.textLabel.text = @"视频分析中...";
        [self hudIncresProgress:0 total:totalFrameCount*3];
    });

    __block NSInteger successIndex = 0;
    __block NSMutableArray *imgInfos = [NSMutableArray array];
    [generator generateCGImagesAsynchronouslyForTimes:timesArray completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        switch (result) {
                
            case AVAssetImageGeneratorFailed:
                returnError = error;
                NSLog(@"视频提取图片失败:%lld,AVAssetImageGeneratorFailed:=%@",requestedTime.value,error);
                break;
                
            case AVAssetImageGeneratorSucceeded:
            {
                // 图片存沙盒按照成功的序数来存，省得出现跳过的序数
                NSString *imgPath = [imgsDiretory stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.jpg", (long)successIndex]];
                NSData *data = UIImageJPEGRepresentation([UIImage imageWithCGImage:image], 1.0);
                NSUInteger frameIndex = requestedTime.value;
                [self hudIncresProgress:frameIndex total:totalFrameCount*3];
                
                if ([data writeToFile:imgPath atomically:YES]) {
                    
                    HTImageInfo *info = [HTImageInfo new];
                    info.index = successIndex;
                    info.currentImgPath = imgPath;
                    [imgInfos addObject:info];
                    successIndex += 1;
                    NSLog(@"视频提取图片成功:%lu",(unsigned long)successIndex);
                    
                    // 全部解析完毕
                    if (frameIndex == totalFrameCount - 1) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"视频提取图片完毕");
                            [[HTMergeManager manager] mergeImageInfos:imgInfos progress:^(NSInteger progress,NSInteger fator) {
                                if (fator == 1) {
                                    self.HUD.textLabel.text = @"图片计算中...";
                                }
                                
                                if (fator == 2) {
                                    self.HUD.textLabel.text = @"长图合成中...";
                                }
                                
                                NSInteger realProgress = fator *totalFrameCount + progress;
                                [self hudIncresProgress:realProgress total:totalFrameCount*3];
                            } finish:^(BOOL success, NSString * _Nonnull imagePath) {
                                [self hudIncresProgress:totalFrameCount*3 total:totalFrameCount*3];
                                [self showPreViewWithImagePath:imagePath];
                            }];
                        });
                    }
                } else {
                    NSLog(@"视频提取图片Failed:%lld,AVAssetImageGeneratorFailed:=%@",requestedTime.value,error);
                    [generator cancelAllCGImageGeneration];
                }
            }
                break;
            default:
                break;
        }
    }];
    
    return returnError;
}


- (JGProgressHUD *)HUD{
    if (!_HUD) {
        _HUD = [[JGProgressHUD alloc] init];
        _HUD.style = JGProgressHUDStyleDark;
        _HUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] init];
        _HUD.detailTextLabel.text = @"0% Complete";
    }
    return _HUD;
}



@end
