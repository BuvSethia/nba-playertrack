//
//  BarGraphViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 9/10/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//  http://www.raywenderlich.com/13271/how-to-draw-graphs-with-core-plot-part-2

#import "BarGraphViewController.h"
#import "SWRevealViewController.h"
#import "Player.h"

@interface BarGraphViewController ()

@end

@implementation BarGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
    }
    
    [self initPlot];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.revealViewController)
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    //NSLog(@"%d", self.statsToGraph.count);
    return self.statsToGraph.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    NSMutableArray *statDataFromRecordIndex = [self.normalizedStatsToGraph objectForKey:self.xAxisDescriptors[index]];
    
    if(fieldEnum == CPTBarPlotFieldBarTip)
    {
        for(int i = 0; i < self.playersToGraph.count; i++)
        {
            Player *player = self.playersToGraph[i];
            NSString *plotName = (NSString*)plot.identifier;
            if([player.name isEqualToString: plotName])
            {
                return statDataFromRecordIndex[i];
            }
        }
    }
    
    return [NSDecimalNumber numberWithUnsignedInteger:index];
}

#pragma mark - CPTBarPlotDelegate methods
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
    
}

#pragma mark - Chart behavior
-(void)initPlot {
    self.hostView.allowPinchScaling = NO;
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
    [self configureAnnotations];
    [self configureLegend];
    [self displayImageOfGraph];
}

-(void)configureGraph
{
    //Create Graph
    CGRect newFrame = CGRectMake(self.hostView.bounds.origin.x, self.hostView.bounds.origin.y, self.hostView.bounds.size.width, self.hostView.bounds.size.height);
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:newFrame];
    graph.plotAreaFrame.masksToBorder = NO;
    self.hostView.hostedGraph = graph;
    
    //Graph Theme
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    graph.paddingBottom = 30.0f;
    graph.paddingLeft  = 10.0f;
    graph.paddingTop    = -1.0f;
    graph.paddingRight  = -5.0f;
    
    //Graph Title
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor blackColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    
    NSString *title = @"NBA PlayerTrack Stats Comparison";
    graph.title = title;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, -15.0f);
    
    //Create Plot Spaces
    CGFloat xMin = 0.0f;
    CGFloat xMax = self.statsToGraph.count;
    CGFloat yMin = 0.0f;
    CGFloat yMax = 1.5f * [self determineMaxYForGraph];  // should determine dynamically based on max price
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
}

-(float)determineMaxYForGraph
{
    float max = 0;
    
    for(NSString *statType in self.xAxisDescriptors)
    {
        NSMutableArray *statsForType = [self.normalizedStatsToGraph objectForKey:statType];
        for(NSString *stat in statsForType)
        {
            if([stat floatValue] > max)
            {
                max = [stat floatValue];
            }
        }
    }
    
    return max;
}

-(void)configurePlots {
    //Create a plot for each player
    NSMutableArray *plotList = [[NSMutableArray alloc] init];
    for(int i = 0; i < self.playersToGraph.count; i++)
    {
        Player *player = self.playersToGraph[i];
        CPTBarPlot *newPlot;
        if(i == 0)
        {
            newPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
        }
        else if(i == 1)
        {
            newPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor] horizontalBars:NO];
        }
        else
        {
            newPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
        }
        
        newPlot.identifier = player.name;
        [plotList addObject:newPlot];
    }
    
    // 2 - Set up line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineColor = [CPTColor lightGrayColor];
    barLineStyle.lineWidth = 0.5;
    // 3 - Add plots to graph
    CPTGraph *graph = self.hostView.hostedGraph;
    CGFloat barX = 0.25f;
    for (CPTBarPlot *plot in plotList){
        plot.dataSource = self;
        plot.delegate = self;
        plot.barWidth = CPTDecimalFromDouble(0.25f);
        plot.barOffset = CPTDecimalFromDouble(barX);
        plot.lineStyle = barLineStyle;
        [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
        barX += 0.25f;
        NSLog(@"Added plot %@ to graph", plot.identifier);
    }
}

-(void)configureAxes
{
    // 1 - Configure styles
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:1];
    // 2 - Get the graph's axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure the x-axis
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.xAxis.axisLineStyle = axisLineStyle;
    // 4 - Configure the y-axis
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.yAxis.axisLineStyle = axisLineStyle;
    
    //Put labels on the x-axis
    //http://stackoverflow.com/questions/2904562/how-do-you-provide-labels-for-the-axis-of-a-core-plot-chart
    axisSet.xAxis.labelRotation = M_PI/4;
    NSMutableArray *customTickLocations = [[NSMutableArray alloc] init];
    for(int i = 0; i < self.xAxisDescriptors.count; i++)
    {
        [customTickLocations addObject:[NSNumber numberWithInt:(i + 1)]];
    }
    NSUInteger labelLocation = 0;
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[self.xAxisDescriptors count]];
    
    //Text Style
    
    CPTMutableTextStyle *style = [CPTMutableTextStyle textStyle];
    style.color= [CPTColor blackColor];
    style.fontSize = 9.5f;
    style.fontName = @"Helvetica";
    style.textAlignment = CPTTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    
    for (NSNumber *tickLocation in customTickLocations) {
        NSString *label = [[self.xAxisDescriptors objectAtIndex:labelLocation++] stringByReplacingOccurrencesOfString:@"- " withString:@"-\n"];
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:label textStyle:style];
        NSNumber *labelLocation = [NSNumber numberWithFloat:([tickLocation floatValue]- 0.5f)];
        newLabel.tickLocation = [labelLocation decimalValue];
        newLabel.offset = axisSet.xAxis.labelOffset + axisSet.xAxis.majorTickLength - 5.0f;
        [customLabels addObject:newLabel];
    }
    
    axisSet.xAxis.axisLabels =  [NSSet setWithArray:customLabels];
}

-(void)configureAnnotations
{
    NSArray *allPlots = self.hostView.hostedGraph.allPlots;
    
    //Create text style for annotation
    static CPTMutableTextStyle *style = nil;
    if (!style) {
        style = [CPTMutableTextStyle textStyle];
        style.color= [CPTColor blackColor];
        style.fontSize = 13.0f;
        style.fontName = @"Helvetica-Bold";
    }
    for(int k = 0; k < self.statsToGraph.count; k++)
    {
        NSUInteger index = (long) k;
        
        for(int j = 0; j < allPlots.count; j++)
        {
            CPTBarPlot *plot = allPlots[j];
        
            //Get data for annotation
            NSNumber *stat;
            NSString *selectedStatType = self.xAxisDescriptors[index];
            NSMutableArray *statsFromStatType = [self.statsToGraph objectForKey:selectedStatType];
            stat = [[NSNumber alloc] initWithFloat:[statsFromStatType[j] floatValue]];
            NSLog(@"Stat annotation value %@", stat);
        
            //Get the anchor point for annotation
            CGFloat x = index + 0.25 + (j * 0.25);
            NSNumber *anchorX = [NSNumber numberWithFloat:x];
            CGFloat y = [[self numberForPlot:plot field:CPTBarPlotFieldBarTip recordIndex:index] floatValue] + 0.05f;
            NSNumber *anchorY = [NSNumber numberWithFloat:y];
        
            CPTPlotSpaceAnnotation *statAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:[NSArray arrayWithObjects:anchorX, anchorY, nil]];
        
            //Create text layer for annotation
            NSString *statValue = [[NSString stringWithFormat:@"%@", stat] stringByReplacingOccurrencesOfString:@"0." withString:@"."];
            CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:statValue style:style];
        
            //Set annotation values
            statAnnotation.contentLayer = textLayer;
            statAnnotation.displacement = CGPointMake(0.0f, 0.0f);
        
            //Add the annotation
            [plot.graph.plotAreaFrame.plotArea addAnnotation:statAnnotation];
        }
    }
}

-(void)configureLegend
{
    // 1 - Get graph instance
    CPTGraph *graph = self.hostView.hostedGraph;
    // 2 - Create legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    // 3 - Configure legend
    theLegend.numberOfColumns = self.playersToGraph.count;
    theLegend.numberOfRows = 1;
    theLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    //theLegend.borderLineStyle = [CPTLineStyle lineStyle];
    //theLegend.cornerRadius = 5.0;
    // 4 - Add legend to graph
    graph.legendAnchor = CPTRectAnchorTop;
    CGFloat legendPadding = self.navigationController.navigationBar.frame.size.height;
    graph.legendDisplacement = CGPointMake(0.0, legendPadding);
    graph.legend = theLegend;
    [self.hostView setHostedGraph:graph];
}

- (IBAction)editDataPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//http://stackoverflow.com/questions/9257992/how-to-combine-merge-2-images-into-1
- (IBAction)saveGraphPressed:(id)sender
{
    //Combine the legend and the graph into one image by creating an image out of the view presenting them.
    UIGraphicsBeginImageContext(self.presentedImagesView.bounds.size);
    [self.presentedImagesView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *combinedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Save combined image to gallery
    UIImageWriteToSavedPhotosAlbum(combinedImage, nil, nil, nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Graph saved to image gallery" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [alert show];
}

-(void)displayImageOfGraph
{
    UIImage *graphImage = [self.hostView.hostedGraph imageOfLayer];
    //graphImage = [self resizeImage:graphImage imageSize:self.graphImageView.bounds.size];
    UIImage *legendImage = [self.hostView.hostedGraph.legend imageOfLayer];
    [self.hostView setHostedGraph:nil];
    [self.hostView setHidden:YES];
    //[self.view bringSubviewToFront:self.legendImageView];
    [self.graphImageView setImage:graphImage];
    [self.legendImageView setImage:legendImage];
}

//http://stackoverflow.com/questions/12552785/resizing-image-to-fit-uiimageview
-(UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //here is the scaled image which has been changed to the size specified
    UIGraphicsEndImageContext();
    return newImage;
    
}

/*
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

-(BOOL)shouldAutorotate
{
    return NO;
}
*/

@end
