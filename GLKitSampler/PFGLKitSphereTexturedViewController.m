//
//  PFGLKitSphereViewController.m
//  GLKitSampler
//
//  Created by Jim Hillhouse on 3/15/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import "PFGLKitSphereTexturedViewController.h"

#import <CoreMotion/CoreMotion.h>



#define BUFFER_OFFSET(i) ((char *)NULL + (i))


//
// This is for the sphere. This and the sphere generation code will be moved shortly to it's own
// code.
//
#define THETA_STEPS 40
#define PHI_STEPS	40
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




@interface PFGLKitSphereTexturedViewController () <UIGestureRecognizerDelegate>
{
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    CMMotionManager *_motionMgr;
    
    GLfloat sphereVertices[ARRAY_LENGTH][3 + 3 + 2];
    GLushort sphereIndices[INDEX_LENGTH];
    int globeMaxIndex;
    
    GLfloat distance;
    GLfloat updater;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
//@property (strong, nonatomic) GLKReflectionMapEffect *effect;
@property (strong, nonatomic) GLKSkyboxEffect *skybox;

@property (strong, nonatomic) CMAttitude *referenceFrame;

- (void)createSphere;

// GL Calls
- (void)setupGL;
- (void)tearDownGL;

@end




@implementation PFGLKitSphereTexturedViewController



@synthesize pitchLabel  = _pitchLabel;
@synthesize rollLabel   = _rollLabel;

@synthesize context = _context;
@synthesize effect  = _effect;
@synthesize skybox  = _skybox;

@synthesize referenceFrame = _referenceFrame;



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
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else 
    {
        return YES;
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
		float t1 = a / PHI_STEPS;
		float y1 = cos(M_PI * a / PHI_STEPS);
		float b;
		for (b = 0; b < THETA_STEPS + 1; b++) 
		{
			float s1 = b / THETA_STEPS;
			float x1 = sin(TWO_PI * b / THETA_STEPS) * sin(M_PI * a / PHI_STEPS);
			float z1 = cos(TWO_PI * b / THETA_STEPS) * sin(M_PI * a / PHI_STEPS);
            
            float n1 = x1;
            float n2 = y1;
            float n3 = z1;
			
            // Vertices
			sphereVertices[count][0] = x1;
			sphereVertices[count][1] = y1;
			sphereVertices[count][2] = z1;
            
            float normalizer = sqrtf(x1 * x1 + y1 * y1 + z1 * z1);
            
            // Vertex Normals -- A hack for now
            sphereVertices[count][3] = n1 / normalizer;
            sphereVertices[count][4] = n2 / normalizer;
			sphereVertices[count][5] = n3 / normalizer;
            
            // Textures
            sphereVertices[count][6] = s1;
			sphereVertices[count][7] = t1;
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
    
    
    [self createSphere];
    
    glEnable(GL_DEPTH_TEST);
    
    
    //
    // Lighting
    //
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled  = GL_TRUE;
    
    GLfloat ambientColor    = 0.70f;
    GLfloat alpha = 1.0f;
    self.effect.light0.ambientColor = GLKVector4Make(ambientColor, ambientColor, ambientColor, alpha);
    
    GLfloat diffuseColor    = 1.0f;
    self.effect.light0.diffuseColor = GLKVector4Make(diffuseColor, diffuseColor, diffuseColor, alpha);
    
    // Spotlight
    GLfloat specularColor   = 1.00f;
    self.effect.light0.specularColor    = GLKVector4Make(specularColor, specularColor, specularColor, alpha);
    self.effect.light0.position         = GLKVector4Make(10.0f, 5.0f, 5.0f, 0.0f);
    self.effect.light0.spotDirection    = GLKVector3Make(0.0f, 0.0f, -1.0f);
    self.effect.light0.spotCutoff       = 20.0; // 40° spread total.
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    
    
    //
    // This is where the vertex data is brought into the app!
    //
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereVertices), sphereVertices, GL_STATIC_DRAW);
    
    
    //
    // Vertices, Normals, and Textures
    //
    // Vertices
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0)); // for model, normals, and texture
    
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12)); // for model, normals, and texture
    
    // Texture
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24)); // for model and texture only
    
    
    glBindVertexArrayOES(0);
    
    
    //
    // Load the texture for the model
    //
    NSDictionary *modelTextureOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithBool:NO], GLKTextureLoaderOriginBottomLeft, 
                                         [NSNumber numberWithBool:NO], GLKTextureLoaderGrayscaleAsAlpha, 
                                         [NSNumber numberWithBool:YES], GLKTextureLoaderApplyPremultiplication,
                                         [NSNumber numberWithBool:NO], GLKTextureLoaderGenerateMipmaps, nil];    
    NSString *texturePath       = [[NSBundle mainBundle] pathForResource:@"MoonMap_2500x1250" ofType:@"jpg"];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:texturePath options:modelTextureOptions error:nil];
    
    self.effect.texture2d0.name = textureInfo.name;
    self.effect.texture2d0.enabled = TRUE;
    
    //
    // Set-up the SkyBox
    //
    NSError *error;
    NSDictionary *cubeTextureOptions    = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft,
                                           [NSNumber numberWithBool:YES], GLKTextureLoaderApplyPremultiplication, nil];
    
    NSString *cubemapTexturePath        = [[NSBundle mainBundle] pathForResource:@"Stars" ofType:@"png"];
    GLKTextureInfo *cubemapTextureInfo  = [GLKTextureLoader cubeMapWithContentsOfFile:cubemapTexturePath options:cubeTextureOptions error:nil];
    
    self.skybox                     = [[GLKSkyboxEffect alloc] init];
    
    self.skybox.center              = GLKVector3Make(0.0f, 0.0f, 0.0f);
    self.skybox.textureCubeMap.name = cubemapTextureInfo.name;
    self.skybox.textureCubeMap.enabled = TRUE;
    
    self.skybox.xSize               = 50.0;
    self.skybox.ySize               = 50.0;
    self.skybox.zSize               = 50.0;
    self.skybox.label               = @"Skybox";
    
    // SkyBox Reflection
    //    self.effect.textureCubeMap.name = self.skybox.textureCubeMap.name;
    //    self.effect.textureCubeMap.enabled = TRUE;
    
    
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
    //GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
    //baseModelViewMatrix = GLKMatrix4Translate(baseModelViewMatrix, 0.0f, 0.0f, distance);
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, distance);
    
    
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
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(_rotation / 4.0, 0.0f, 1.0f, 0.0f);
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
    
    // Need to create an indices array.
    glDrawElements(GL_TRIANGLE_STRIP, globeMaxIndex, GL_UNSIGNED_SHORT, sphereIndices);
    
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
