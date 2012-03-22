//
//  PFGLKitSquareSampleViewController.m
//  GLKitSampler
//
//  Created by Jim Hillhouse on 3/1/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import "PFGLKitSquareSampleViewController.h"

#import <CoreMotion/CoreMotion.h>



#define BUFFER_OFFSET(i) ((char *)NULL + (i))



// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];




// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};




//
//GLfloat gCubeVertexData[216] = 
//
// three x, y, z coordinates
// four bytes per GLFloat coordinate
//
GLfloat gSquareVertexData[(3) * 4] = 
{
    -1,  1,  1,
    -1, -1,  1,
     1, -1,  1,
     1,  1,  1,
};




@interface PFGLKitSquareSampleViewController () <UIGestureRecognizerDelegate>
{
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    CMMotionManager *_motionMgr;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) GLKSkyboxEffect *skybox;

@property (strong, nonatomic) CMAttitude *referenceFrame;

- (void)setupGL;
- (void)tearDownGL;

@end




@implementation PFGLKitSquareSampleViewController



@synthesize pitchLabel  = _pitchLabel;
@synthesize rollLabel   = _rollLabel;

@synthesize context = _context;
@synthesize effect  = _effect;
@synthesize skybox  = _skybox;

@synthesize referenceFrame = _referenceFrame;




#pragma mark - View Life

- (void)viewDidLoad
{
    NSLog(@"PFGLKitSquareSampleViewController -viewDidLoad");
    
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) 
    {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
}



- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) 
    {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else 
    {
        return YES;
    }
}



- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    
    glEnable(GL_DEPTH_TEST);
    
    
    //
    // Lighting
    //
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled  = GL_FALSE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(gSquareVertexData), gSquareVertexData, GL_STATIC_DRAW);
    
    
    //
    // Vertices
    //
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 12, BUFFER_OFFSET(0)); // for model only 
    
    glBindVertexArrayOES(0);
    
    
    //
    // Set-up the SkyBox
    //
    NSString *cubemapTexturePath        = [[NSBundle mainBundle] pathForResource:@"HubblePanoramic_512" ofType:@"png"];
    GLKTextureInfo *cubemapTextureInfo  = [GLKTextureLoader cubeMapWithContentsOfFile:cubemapTexturePath options:nil error:nil];
    
    self.skybox                     = [[GLKSkyboxEffect alloc] init];
    
    self.skybox.center              = GLKVector3Make(0.0f, 0.0f, 0.0f);
    self.skybox.textureCubeMap.name = cubemapTextureInfo.name;
    self.skybox.textureCubeMap.enabled = TRUE;
    
    self.skybox.xSize               = 20.0;
    self.skybox.ySize               = 20.0;
    self.skybox.zSize               = 20.0;
    self.skybox.label               = @"Skybox";
    
    
    //
    // Set-up Core Motion
    //
    _motionMgr = [[CMMotionManager alloc] init];
    if ([_motionMgr isDeviceMotionAvailable]) 
    {
        [_motionMgr startDeviceMotionUpdates];
    }
    
    self.referenceFrame = nil;
}



- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    self.skybox = nil;
}



#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    self.skybox.transform.projectionMatrix = projectionMatrix;
    
    
    //
    // Rotation then translation. 
    // A Rotation of 180° to place the face of the body, in this case the Moon, correctly.
    //
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
    baseModelViewMatrix = GLKMatrix4Translate(baseModelViewMatrix, 0.0f, 0.0f, 5.0f);
    
    
    //
    // Insert Core Motion if avaialble
    //
    if ([_motionMgr isDeviceMotionAvailable]) 
    {
        CMDeviceMotion *motion = [_motionMgr deviceMotion];

        CMAttitude *attitude = motion.attitude;
        
        if (!self.referenceFrame) 
        {
            NSLog(@"reference frame is nil...setting it to the current attitude.");
            self.referenceFrame = motion.attitude;
        } 
        else 
        {
            [attitude multiplyByInverseOfAttitude:self.referenceFrame];
        }
        
        GLfloat pitchAngle  = 2.0 * attitude.pitch;
        GLfloat rollAngle   = 2.0 * attitude.roll;
        
        GLKMatrix4 rollMatrix   = GLKMatrix4MakeYRotation(rollAngle);
        GLKMatrix4 pitchMatrix  = GLKMatrix4MakeXRotation(pitchAngle);
        
        GLKMatrix4 modelViewMatrix = rollMatrix;
        modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, pitchMatrix);
        
        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
        
        self.effect.transform.modelviewMatrix = modelViewMatrix;
        self.skybox.transform.modelviewMatrix = modelViewMatrix;
        
        
        //
        // Update yaw, pitch, and roll labels
        //
        [self.pitchLabel setText:[NSString stringWithFormat:@"%6.2f""°", GLKMathRadiansToDegrees(pitchAngle)]];            
        [self.rollLabel setText:[NSString stringWithFormat:@"%6.2f""°", GLKMathRadiansToDegrees(rollAngle)]];        
        
    }
    else
    {
        baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
        
        // Compute the model view matrix for the object rendered with GLKit
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(_rotation, 1.0f, 1.0f, 1.0f);
        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
        
        self.effect.transform.modelviewMatrix = modelViewMatrix;
        
        // Compute model view matrix for the skybox -- similar but slower, opposite rotation
        modelViewMatrix = GLKMatrix4MakeRotation(-_rotation/1.5, 1.0f, 1.0f, 1.0f);
        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
        
        _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
        
        _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
        
        self.skybox.transform.modelviewMatrix = modelViewMatrix;
    }
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
}



- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.16f, 0.32f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render the skybox
    [self.skybox prepareToDraw];
    [self.skybox draw];
    
    glBindVertexArrayOES(_vertexArray);
    
    // Render the object with GLKit
    [self.effect prepareToDraw];
    
    glPointSize(10.0);
    
    glDrawArrays(GL_LINE_LOOP, 0, 4); // For square.
}



#pragma mark - Reference Frame

- (IBAction)resetReferenceFrame:(id)sender
{
    if ([_motionMgr isDeviceMotionActive]) 
    {
        self.referenceFrame = [[_motionMgr deviceMotion] attitude];
    }
}



@end
