//
//  PDFReaderPlugin.m
//  FJMZT
//
//  Created by Dongfuming on 2018/7/27.
//  Copyright © 2018年 MZT. All rights reserved.
//

#import "PDFReaderPlugin.h"
#import "KGPDFViewController.h"
#import "AppDelegate.h"

#define kPdfDirectoryName @"PdfFile"
#define kPdfFileName @"testFile.pdf"

@implementation PDFReaderPlugin


- (void)location:(CDVInvokedUrlCommand *)commmand
{
    //NSString *directoryPath = [self getPdfFileDirectoryPath];
    //NSString *pdfFilePath = [directoryPath stringByAppendingPathComponent:kPdfFileName];
    NSString *pdfFilePath = [[NSBundle mainBundle] pathForResource:@"testFile.pdf" ofType:nil];
    [self openPdfWithFilePath:pdfFilePath encrypted:YES];
    
    CDVPluginResult *pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"打开pdf成功"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:commmand.callbackId];
}

- (void)openPdfWithFilePath:(NSString *)filePath encrypted:(BOOL)encrypted
{
    if (! [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSLog(@"文档不存在！");
        return;
    }
    // 创建PDF阅读器
    KGPDFViewController *pdfVC = [[KGPDFViewController alloc] init];
    pdfVC.isReadonly = YES;
    //pdfVC.delegate = self;
    pdfVC.username = @"A732";
    pdfVC.filePath = filePath;
    pdfVC.destText = @"";
    pdfVC.isEncrypted = encrypted;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *rootVC = appDelegate.window.rootViewController;
    [rootVC presentViewController:pdfVC animated:YES completion:nil];
}

#pragma mark - Helper
/** 存放pdf的文件夹，若无则创建 */
- (NSString *)getPdfFileDirectoryPath
{
    NSString *directoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:kPdfDirectoryName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:directoryPath];
    if (! exist) {
        BOOL success = [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (! success) { return nil; }
    }
    return directoryPath;
}

@end
