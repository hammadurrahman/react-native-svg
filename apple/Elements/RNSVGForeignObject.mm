/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */
#import "RNSVGForeignObject.h"
#import "RNSVGClipPath.h"
#import "RNSVGMask.h"
#import "RNSVGNode.h"

#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTConversions.h>
#import <React/RCTFabricComponentsPlugins.h>
#import <react/renderer/components/view/conversions.h>
#import <rnsvg/RNSVGComponentDescriptors.h>
#import "RNSVGFabricConversions.h"
#endif // RCT_NEW_ARCH_ENABLED

@implementation RNSVGForeignObject

#ifdef RCT_NEW_ARCH_ENABLED
using namespace facebook::react;

// Needed because of this: https://github.com/facebook/react-native/pull/37274
+ (void)load
{
  [super load];
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const RNSVGForeignObjectProps>();
    _props = defaultProps;
  }
  return self;
}

#pragma mark - RCTComponentViewProtocol

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<RNSVGForeignObjectComponentDescriptor>();
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &newProps = static_cast<const RNSVGForeignObjectProps &>(*props);

  id x = RNSVGConvertFollyDynamicToId(newProps.x);
  if (x != nil) {
    self.x = [RCTConvert RNSVGLength:x];
  }
  id y = RNSVGConvertFollyDynamicToId(newProps.y);
  if (y != nil) {
    self.y = [RCTConvert RNSVGLength:y];
  }
  id height = RNSVGConvertFollyDynamicToId(newProps.height);
  if (height != nil) {
    self.foreignObjectheight = [RCTConvert RNSVGLength:height];
  }
  id width = RNSVGConvertFollyDynamicToId(newProps.width);
  if (width != nil) {
    self.foreignObjectwidth = [RCTConvert RNSVGLength:width];
  }

  setCommonGroupProps(newProps, self);
  _props = std::static_pointer_cast<RNSVGForeignObjectProps const>(props);
}

- (void)prepareForRecycle
{
  [super prepareForRecycle];
  _x = nil;
  _y = nil;
  _foreignObjectheight = nil;
  _foreignObjectwidth = nil;
}
#endif // RCT_NEW_ARCH_ENABLED
- (RNSVGPlatformView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  return nil;
}

- (void)parseReference
{
  self.dirty = false;
}

- (void)renderLayerTo:(CGContextRef)context rect:(CGRect)rect
{
  [self clip:context];
  CGContextTranslateCTM(context, [self relativeOnWidth:self.x], [self relativeOnHeight:self.y]);
  CGRect clip = CGRectMake(
      0, 0, [self relativeOnWidth:self.foreignObjectwidth], [self relativeOnHeight:self.foreignObjectheight]);
  CGContextClipToRect(context, clip);
  [super renderLayerTo:context rect:rect];
}

- (void)renderGroupTo:(CGContextRef)context rect:(CGRect)rect
{
  [self pushGlyphContext];

  __block CGRect bounds = CGRectNull;

  [self traverseSubviews:^(RNSVGView *node) {
    if ([node isKindOfClass:[RNSVGMask class]] || [node isKindOfClass:[RNSVGClipPath class]]) {
      // no-op
    } else if ([node isKindOfClass:[RNSVGNode class]]) {
      RNSVGNode *svgNode = (RNSVGNode *)node;
      if (svgNode.display && [@"none" isEqualToString:svgNode.display]) {
        return YES;
      }
      if (svgNode.responsible && !self.svgView.responsible) {
        self.svgView.responsible = YES;
      }

      if ([node isKindOfClass:[RNSVGRenderable class]]) {
        [(RNSVGRenderable *)node mergeProperties:self];
      }

      [svgNode renderTo:context rect:rect];

      CGRect nodeRect = svgNode.clientRect;
      if (!CGRectIsEmpty(nodeRect)) {
        bounds = CGRectUnion(bounds, nodeRect);
      }

      if ([node isKindOfClass:[RNSVGRenderable class]]) {
        [(RNSVGRenderable *)node resetProperties];
      }
    } else if ([node isKindOfClass:[RNSVGSvgView class]]) {
      RNSVGSvgView *svgView = (RNSVGSvgView *)node;
      CGFloat width = [self relativeOnWidth:svgView.bbWidth];
      CGFloat height = [self relativeOnHeight:svgView.bbHeight];
      CGRect svgViewRect = CGRectMake(0, 0, width, height);
      CGContextClipToRect(context, svgViewRect);
      [svgView drawToContext:context withRect:svgViewRect];
    } else {
      node.hidden = false;
      [node.layer renderInContext:context];
      node.hidden = true;
    }

    return YES;
  }];
  CGPathRef path = [self getPath:context];
  [self setHitArea:path];
  if (!CGRectEqualToRect(bounds, CGRectNull)) {
    self.clientRect = bounds;
    self.fillBounds = CGPathGetPathBoundingBox(path);
    self.strokeBounds = CGPathGetPathBoundingBox(self.strokePath);
    self.pathBounds = CGRectUnion(self.fillBounds, self.strokeBounds);

    CGAffineTransform current = CGContextGetCTM(context);
    CGAffineTransform svgToClientTransform = CGAffineTransformConcat(current, self.svgView.invInitialCTM);

    self.ctm = svgToClientTransform;
    self.screenCTM = current;

    CGPoint mid = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGPoint center = CGPointApplyAffineTransform(mid, self.matrix);

    self.bounds = bounds;
    if (!isnan(center.x) && !isnan(center.y)) {
      self.center = center;
    }
    self.frame = bounds;
  }

  [self popGlyphContext];
}

- (void)drawRect:(CGRect)rect
{
  [self invalidate];
}

- (void)setX:(RNSVGLength *)x
{
  if ([x isEqualTo:_x]) {
    return;
  }

  _x = x;
  [self invalidate];
}

- (void)setY:(RNSVGLength *)y
{
  if ([y isEqualTo:_y]) {
    return;
  }

  _y = y;
  [self invalidate];
}

- (void)setForeignObjectwidth:(RNSVGLength *)foreignObjectwidth
{
  if ([foreignObjectwidth isEqualTo:_foreignObjectwidth]) {
    return;
  }

  _foreignObjectwidth = foreignObjectwidth;
  [self invalidate];
}

- (void)setForeignObjectheight:(RNSVGLength *)foreignObjectheight
{
  if ([foreignObjectheight isEqualTo:_foreignObjectheight]) {
    return;
  }

  _foreignObjectheight = foreignObjectheight;
  [self invalidate];
}

@end

#ifdef RCT_NEW_ARCH_ENABLED
Class<RCTComponentViewProtocol> RNSVGForeignObjectCls(void)
{
  return RNSVGForeignObject.class;
}
#endif // RCT_NEW_ARCH_ENABLED
