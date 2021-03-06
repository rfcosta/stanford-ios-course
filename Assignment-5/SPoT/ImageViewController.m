//
//  ImageViewController.m
//  SPoT
//
//  Created by Jakob Jakobsen Boysen on 08/04/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "ImageViewController.h"
#import "SPoTAppDelegate.h"
#import "PhotoCache.h"

@interface ImageViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic)  BOOL userHasZoomed;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation ImageViewController

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        [self.spinner startAnimating];
        
        if (!self.imageURL) { // on the iPad this view is shown immideately, this checks that we actually clicked an item in the table views
            [self.spinner stopAnimating];
        } else {
            dispatch_queue_t loaderQ = dispatch_queue_create("image fetcher", NULL);
            dispatch_async(loaderQ, ^{
                
                UIImage *image = [[UIImage alloc] initWithData:[self getImageData]];
                NSURL* imageURL = self.imageURL;
                
                if (self.imageURL == imageURL) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (image) {
                            self.scrollView.contentSize = image.size;
                            self.imageView.image = image;
                            self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                            [self resetZoom];
                        }
                        [self.spinner stopAnimating];
                    });
                }
            });
        }
    }
}

- (NSData*)getImageData
{
    PhotoCache* cache = [[PhotoCache alloc] init];
    
    NSData *imageData = [cache getValue:self.imageURL];
    
    if (!imageData) {
        [(SPoTAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
        imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL];
        [(SPoTAppDelegate*)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
        [cache setValue:imageData forImageURL:self.imageURL];
    }
    
    return imageData;
}

- (void)resetZoom
{
    if (!self.userHasZoomed && self.imageView.image) {
        CGSize imageSize = self.imageView.image.size;
        
        float scale = self.scrollView.bounds.size.width / imageSize.width;
    
        if (imageSize.height * scale < self.scrollView.bounds.size.height)
            scale = self.scrollView.bounds.size.height / imageSize.height;
    
        self.scrollView.zoomScale = scale;
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    self.userHasZoomed = YES;
}

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

- (BOOL)userHasZoomed
{
    if (!_userHasZoomed) _userHasZoomed = NO;
    return _userHasZoomed;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    [self resetImage];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self resetZoom];
}

@end
