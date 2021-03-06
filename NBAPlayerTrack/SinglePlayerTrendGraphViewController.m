//
//  SinglePlayerTrendGraphViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 9/28/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//  http://www.raywenderlich.com/13271/how-to-draw-graphs-with-core-plot-part-2

#import "SinglePlayerTrendGraphViewController.h"
#import "SWRevealViewController.h"

@interface SinglePlayerTrendGraphViewController ()

@end

@implementation SinglePlayerTrendGraphViewController

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
    return [[self.statsToGraph objectForKey:plot.identifier] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSArray *stats = [self.statsToGraph objectForKey:plot.identifier];
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (index < stats.count) {
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;
            
        case CPTScatterPlotFieldY:
            return [NSNumber numberWithDouble:[stats[index] doubleValue]];
            break;
    }
    return [NSDecimalNumber zero];
}

#pragma mark - Chart behavior
-(void)initPlot {
    self.hostView.allowPinchScaling = NO;
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
    [self configureLegend];
    [self displayImageOfGraph];
}

-(void)configureGraph
{
    //Create Graph
    //CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    CGRect newFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:newFrame];
    graph.plotAreaFrame.masksToBorder = NO;
    self.hostView.hostedGraph = graph;
    
    //Graph Theme
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    graph.paddingBottom = 30.0f;
    graph.paddingLeft  = 38.0f;
    graph.paddingTop    = -5.0f;
    graph.paddingRight  = 38.0f;
    
    //Graph Title
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor blackColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    
    NSString *title = @"NBA PlayerTrack Stats Comparison";
    graph.title = title;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, -1.0f);
}

-(float)determineMaxYForGraph:(NSMutableArray*)valueSet
{
    float max = 0;
    for(NSString *stat in valueSet)
    {
        if([stat floatValue] > max)
        {
            max = [stat floatValue];
        }
    }
    
    return max;
}

-(float)determineMinYForGraph:(NSMutableArray*)valueSet
{
    float min = 0;
    for(NSString *stat in valueSet)
    {
        if([stat floatValue] < min)
        {
            min = [stat floatValue];
        }
    }
    
    return min;
}

-(void)configurePlots
{
    CPTGraph *graph = self.hostView.hostedGraph;
    
    //Create a plot for each player
    for(int i = 0; i < self.statsToGraph.count; i++)
    {
        //Plot
        CPTScatterPlot *newPlot = [[CPTScatterPlot alloc] init];
        newPlot.dataSource = self;
        newPlot.identifier = [[self.statsToGraph allKeys] objectAtIndex:i];
        
        //Plot Space
        CPTXYPlotSpace *plotSpace = [[CPTXYPlotSpace alloc] init];
        CGFloat xMin = 0.0f;
        CGFloat xMax = [[self.statsToGraph objectForKey:[[self.statsToGraph allKeys] objectAtIndex:i]] count];
        CGFloat yMin = 0.0f;
        CGFloat yMax = 1.2f * [self determineMaxYForGraph:[self.statsToGraph objectForKey:[[self.statsToGraph allKeys] objectAtIndex:i]]];
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
        plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax + fabsf(yMin))];        [graph addPlotSpace:plotSpace];
        
        //Styles
        CPTMutableLineStyle *lineStyle = [newPlot.dataLineStyle mutableCopy];
        lineStyle.lineWidth = 2.5;
        if(i == 0)
        {
            lineStyle.lineColor = [CPTColor redColor];
        }
        else if(i == 1)
        {
            lineStyle.lineColor = [CPTColor blueColor];
        }
        else
        {
            lineStyle.lineColor = [CPTColor greenColor];
        }
        newPlot.dataLineStyle = lineStyle;
        CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
        symbolLineStyle.lineColor = lineStyle.lineColor;
        CPTPlotSymbol *symbol = [CPTPlotSymbol ellipsePlotSymbol];
        symbol.fill = [CPTFill fillWithColor:lineStyle.lineColor];
        symbol.lineStyle = symbolLineStyle;
        symbol.size = CGSizeMake(5.0f, 5.0f);       
        newPlot.plotSymbol = symbol;
        
        [graph addPlot:newPlot toPlotSpace:plotSpace];
    }
}

-(void)configureAxes
{
    //Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor blackColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 15.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor blackColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor blackColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    
    //Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
    //Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    x.title = @"Month";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    x.majorIntervalLength = CPTDecimalFromCGFloat(1.0f);
    NSMutableArray *monthsAlreadyLabeled = [[NSMutableArray alloc] init];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:[[[NSSet setWithArray:self.monthsBeingGraphed] allObjects] count]];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:[[[NSSet setWithArray:self.monthsBeingGraphed] allObjects] count]];
    NSInteger i = 0;
    for (NSString *month in self.monthsBeingGraphed) {
        
        bool shouldCreateLabel = YES;
        for(NSString *s in monthsAlreadyLabeled)
        {
            if([s isEqualToString:month])
            {
                shouldCreateLabel = NO;
            }
        }
        
        if(shouldCreateLabel)
        {
            NSLog(@"New label for month %@", month);
            [monthsAlreadyLabeled addObject:month];
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:month  textStyle:x.labelTextStyle];
            CGFloat location = i++;
            label.tickLocation = CPTDecimalFromCGFloat(location/self.monthsBeingGraphed.count);
            label.offset = x.majorTickLength + 1.0f;
            if (label) {
                [xLabels addObject:label];
                [xLocations addObject:[NSNumber numberWithFloat:location]];
            }
        }
        else
        {
            i++;
        }
    }
    
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    
    //Y axis for each stat type
    NSMutableArray *allAxes = [[NSMutableArray alloc] init];
    for(int j = 0; j < self.statsToGraph.count; j++)
    {
        CPTXYAxis *yAxis = [[CPTXYAxis alloc] init];
        yAxis.coordinate = CPTCoordinateY;
        yAxis.title = [[self.statsToGraph allKeys] objectAtIndex:j];
        yAxis.titleTextStyle = axisTitleStyle;
        yAxis.titleOffset = 19.0f;
        yAxis.axisLineStyle = axisLineStyle;
        yAxis.majorGridLineStyle = gridLineStyle;
        //yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
        yAxis.labelTextStyle = axisTextStyle;
        //yAxis.labelOffset = 16.0f;
        yAxis.majorTickLineStyle = axisLineStyle;
        yAxis.majorTickLength = 2.0f;
        yAxis.minorTickLength = 0.0f;
        yAxis.tickDirection = CPTSignNegative;
        yAxis.titleDirection = CPTSignNegative;
        yAxis.plotSpace = [self.hostView.hostedGraph.allPlotSpaces objectAtIndex:(j + 1)];
        yAxis.majorGridLineStyle = Nil;
        
        if(j == 1)
        {
            yAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(self.monthsBeingGraphed.count);
            //yAxis.titleOffset = 17.0f;
            yAxis.titleDirection = CPTSignPositive;
            yAxis.tickDirection = CPTSignPositive;
        }
        
        /*
         CGFloat majorIncrement = .15f * [self determineMaxYForGraph:[self.statsToGraph objectForKey:[[self.statsToGraph allKeys] objectAtIndex:j]]];
         CGFloat yMax = 1.5f * [self determineMaxYForGraph:[self.statsToGraph objectForKey:[[self.statsToGraph allKeys] objectAtIndex:j]]];
         NSMutableSet *yLabels = [NSMutableSet set];
         NSMutableSet *yMajorLocations = [NSMutableSet set];
         for (CGFloat k = majorIncrement; k <= yMax; k += majorIncrement) {
             CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%f", k] textStyle:yAxis.labelTextStyle];
             NSDecimal location = CPTDecimalFromInteger(k);
             label.tickLocation = location;
             label.offset = -yAxis.majorTickLength - yAxis.labelOffset;
             if (label) {
                 [yLabels addObject:label];
             }
             [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
         }

         yAxis.axisLabels = yLabels;
         yAxis.majorTickLocations = yMajorLocations;
        */
        [allAxes addObject:yAxis];
        
    }
    
    [allAxes addObject:x];
    
    self.hostView.hostedGraph.axisSet.axes = [allAxes copy];
}

-(void)configureLegend
{
    // 1 - Get graph instance
    CPTGraph *graph = self.hostView.hostedGraph;
    // 2 - Create legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    // 3 - Configure legend
    theLegend.numberOfColumns = self.statsToGraph.count;
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
@end
