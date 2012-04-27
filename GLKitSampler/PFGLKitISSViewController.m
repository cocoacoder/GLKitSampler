//
//  PFGLKitSphereViewController.m
//  GLKitSampler
//
//  Created by Jim Hillhouse on 3/15/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import "PFGLKitISSViewController.h"

#import <CoreMotion/CoreMotion.h>
#import "ISS_LowRes.h"



#define BUFFER_OFFSET(i) ((char *)NULL + (i))


//
// This is for the sphere. This and the sphere generation code will be moved shortly to it's own
// code.
//
#define THETA_STEPS 10
#define PHI_STEPS	10
#define ARRAY_LENGTH ((THETA_STEPS + 1) * (PHI_STEPS + 1))
#define INDEX_LENGTH (3 * ARRAY_LENGTH)



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




static BOOL readModel = NO;




@interface PFGLKitISSViewController () <UIGestureRecognizerDelegate>
{
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    CMMotionManager *_motionMgr;
    
    GLfloat sphereVertices[ARRAY_LENGTH][3];
    GLushort sphereIndices[INDEX_LENGTH];
    int globeMaxIndex;
    
    GLfloat distance;
    GLfloat updater;
}

@property (strong, nonatomic)   EAGLContext *context;
@property (strong, nonatomic)   GLKBaseEffect *effect;
@property (strong, nonatomic)   GLKSkyboxEffect *skybox;

@property (strong, nonatomic)   CMAttitude *referenceFrame;

@property (strong,nonatomic) NSData *meshData;

- (void)createSphere;

- (void)setupGL;
- (void)tearDownGL;

- (void)thrustImpulse;
- (void)rotationImpulse;

@end




@implementation PFGLKitISSViewController



@synthesize pitchLabel  = _pitchLabel;
@synthesize rollLabel   = _rollLabel;

@synthesize context = _context;
@synthesize effect  = _effect;
@synthesize skybox  = _skybox;

@synthesize referenceFrame = _referenceFrame;

@synthesize meshData = _meshData;




#pragma mark - View Life

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) 
    {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view   = (GLKView *)self.view;
    view.context    = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    distance    = -3.0f;
    updater     =  0.0f;    
    
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
    
    distance    = -3.0f;
    updater     =  0.0f;
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
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } 
    else 
    {
        return ( (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
    }
}



# pragma mark - Sphere Generation Code

- (void)createSphere
{
	int count = 0;
	float TWO_PI = 2.0 * M_PI;
	float a;
	for (a = 0; a < PHI_STEPS + 1; a++)
	{
		float y1 = cos(M_PI * a / PHI_STEPS);
		float b;
		for (b = 0; b < THETA_STEPS + 1; b++) 
		{
			float x1 = sin(TWO_PI * b / THETA_STEPS) * sin(M_PI * a / PHI_STEPS);
			float z1 = cos(TWO_PI * b / THETA_STEPS) * sin(M_PI * a / PHI_STEPS);
            
            // Vertices
			sphereVertices[count][0] = x1;
			sphereVertices[count][1] = y1;
			sphereVertices[count][2] = z1;

			++count;
		}
	}
	
	int i, j;
	count = 0;
	for (j = 0; j < PHI_STEPS; j++) 
	{
		int firstElement = j * (THETA_STEPS + 1);
		for (i = 0; i < THETA_STEPS + 1; i++) 
		{       
			sphereIndices[count]        = firstElement + i;
			sphereIndices[count + 1]    = firstElement + i + THETA_STEPS + 1;
			count += 2;
		}
	}
    
    globeMaxIndex = count;
}



- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    
    //[self createSphere];
    
    glEnable(GL_DEPTH_TEST);
    
    
    
    //
    // NSDATA READ-IN
    //
    // This is to test whether an NSData object can be used as a storage for large static arrays
    //
    // NOTE:
    //
    // I want to thank Jason Moore and Duane Cawthron for their help in both writing code and opening
    // my eyes to working with NSData. Thank you guys.
    //
    
    if (readModel) 
    {
        // Compliments of Jason Moore
        NSData *copyMeshArrayData = [NSData dataWithBytesNoCopy:(void *)ISS_LowRes_MeshVertexData length:sizeof(ISS_LowRes_MeshVertexData)];
        
        [copyMeshArrayData writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"ISS_LowRes.bytes"]
                            atomically:NO];
        
        NSLog(@"size of array: %lu", sizeof(ISS_LowRes_MeshVertexData));
        NSLog(@"length of NSData: %d", [copyMeshArrayData length]);
    }
    
    
    //
    // NSDATA READ-OUT
    //
    // Create a path to the file of bytes and associate an NSData object with that file.
    //
    
    // Compliments of Jason Moore
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ISS_LowRes" ofType:@"bytes"];
    NSData *meshArrayData = [NSData dataWithContentsOfFile:path];
    self.meshData = meshArrayData;
    
    //NSLog(@"size of array: %lu", sizeof(ISS_LowRes_MeshVertexData));
    //NSLog(@"length of NSData: %d", [meshArrayData length]);
    
    
    //
    // Lighting
    //
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled  = GL_TRUE;
    
    GLfloat ambientColor    = 0.90f;
    GLfloat alpha = 1.0f;
    self.effect.light0.ambientColor = GLKVector4Make(ambientColor, ambientColor, ambientColor, alpha);
    
//    GLfloat diffuseColor    = 0.75f;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, alpha);
    
    // Spotlight
    GLfloat specularColor   = 1.0f;
    self.effect.light0.specularColor    = GLKVector4Make(specularColor, specularColor, specularColor, alpha);
    self.effect.light0.position         = GLKVector4Make(5.0f, 10.0f, 10.0f, 0.0);
    self.effect.light0.spotDirection    = GLKVector3Make(0.0f, 0.0f, -1.0f);
    self.effect.light0.spotCutoff       = 20.0; // 40° spread total.
    
    self.effect.lightingType = GLKLightingTypePerPixel;

    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    
    //glBufferData(GL_ARRAY_BUFFER, sizeof(ISS_LowRes_MeshVertexData), ISS_LowRes_MeshVertexData, GL_STATIC_DRAW);
    glBufferData(GL_ARRAY_BUFFER, [self.meshData length], [self.meshData bytes], GL_STATIC_DRAW);

    //
    // Vertices
    //
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(vertexDataTextured), 0); // for model, normals, and texture
    
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(vertexDataTextured), (char *)12); // for model, normals, and texture
    
    // Texture
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(vertexDataTextured), (char *)24); // for model and texture only

    
    glBindVertexArrayOES(0);
    
    
    //
    // Load the texture for the model
    //
    NSDictionary *modelTextureOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, 
                                         [NSNumber numberWithBool:NO], GLKTextureLoaderGrayscaleAsAlpha, 
                                         [NSNumber numberWithBool:YES], GLKTextureLoaderApplyPremultiplication,
                                         [NSNumber numberWithBool:NO], GLKTextureLoaderGenerateMipmaps, nil];    
    NSString *texturePath       = [[NSBundle mainBundle] pathForResource:@"Brushed_Aluminum_Dark" ofType:@"png"];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:texturePath options:modelTextureOptions error:nil];
    
    self.effect.texture2d0.name = textureInfo.name;
//    self.effect.texture2d0.enabled = TRUE;
    
    
    GLKEffectPropertyTexture *tex = [[GLKEffectPropertyTexture alloc] init];
 //   tex.enabled = YES;
    tex.envMode = GLKTextureEnvModeDecal;
    tex.name = self.effect.texture2d0.name;
    
    self.effect.texture2d0.name = tex.name;
    
        
    
    //
    // Set-up the SkyBox
    //
    NSString *cubemapTexturePath        = [[NSBundle mainBundle] pathForResource:@"Stars" ofType:@"png"];
    GLKTextureInfo *cubemapTextureInfo  = [GLKTextureLoader cubeMapWithContentsOfFile:cubemapTexturePath options:nil error:nil];
    
    self.skybox                     = [[GLKSkyboxEffect alloc] init];
    
    self.skybox.center              = GLKVector3Make(0.0f, 0.0f, 0.0f);
    self.skybox.textureCubeMap.name = cubemapTextureInfo.name;
    self.skybox.textureCubeMap.enabled = TRUE;
    
    self.skybox.xSize               = 50.0;
    self.skybox.ySize               = 50.0;
    self.skybox.zSize               = 50.0;
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
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 250.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    self.skybox.transform.projectionMatrix = projectionMatrix;
    
    
    //
    // Rotation then translation. 
    // A Rotation of 180° to place the face of the body, in this case the Moon, correctly.
    //
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeRotation( M_PI_2, 1.0f, 0.0f, 0.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, -M_PI_2, 0.0f, 1.0f, 0.0f);
    baseModelViewMatrix = GLKMatrix4Translate(baseModelViewMatrix, 0.0f, 2.0f * distance, 0.0f);
//    baseModelViewMatrix = GLKMatrix4Scale(baseModelViewMatrix, 0.5, 0.5, 0.5);
    
    //GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 2.0 * distance);
    
    
    //
    // Insert Core Motion if avaialble
    //
    if ([_motionMgr isDeviceMotionAvailable]) 
    {
        CMDeviceMotion *motion = [_motionMgr deviceMotion];
        
        CMAttitude *attitude = motion.attitude;
         
        
        //
        // This resets the reference frame
        //
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
        
        //        NSLog(@"Modified modelViewMatrix %@ \n\n\n\n", NSStringFromGLKMatrix4(modelViewMatrix));
        
        self.effect.transform.modelviewMatrix = modelViewMatrix;
        self.skybox.transform.modelviewMatrix = modelViewMatrix;
        
        
        //
        // Update pitch, and roll labels
        //
        [self.pitchLabel setText:[NSString stringWithFormat:@"%6.2f""°", GLKMathRadiansToDegrees(pitchAngle)]];            
        [self.rollLabel setText:[NSString stringWithFormat:@"%6.2f""°", GLKMathRadiansToDegrees(rollAngle)]];        
    }
    else
    {
        // Compute the model view matrix for the object rendered with GLKit
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(_rotation / 4.0, 0.1f, 1.0f, 0.0f);
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
//    glClearColor(0.16f, 0.32f, 0.65f, 1.0f);
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render the skybox
    [self.skybox prepareToDraw];
    [self.skybox draw];
    
    glBindVertexArrayOES(_vertexArray);
    
    // Render the object with GLKit
    [self.effect prepareToDraw];
    
    glPointSize(10.0);
    
    // Need to create an indices array.
    //glDrawArrays(GL_TRIANGLES, 0, sizeof(ISS_LowRes_MeshVertexData)/ sizeof(vertexDataTextured));
    glDrawArrays(GL_TRIANGLES, 0, [self.meshData length]/sizeof(vertexDataTextured));

}



#pragma mark - Reference Frame

- (IBAction)resetReferenceFrame:(id)sender
{
    if ([_motionMgr isDeviceMotionActive]) 
    {
        self.referenceFrame = [[_motionMgr deviceMotion] attitude];
    }
}



-(void)handleZoomFromGestureRecognizer:(UIPinchGestureRecognizer *)recognizer
{
    NSLog(@"Pinch Gesture Recognizer");
    
    //
    // This sets the spacing between layers.
    //
    updater = [recognizer scale];
    
    NSLog(@"Updater: %f", updater);
    
    if ([recognizer state] == UIGestureRecognizerStateChanged) 
    {
        if ( updater > 1.0 ) 
        {
            // Zoom-in
            if ( distance >= 1.25f ) 
            {
                distance -= updater / 60.0f;
            }
        }
        else
        {
            if ( distance <= 6.0 ) 
            {
                distance += updater / 10.f;
            }
            if ( distance > 6.0 ) 
            {
                distance = 6.0;
            }
        }
    }
}



@end
