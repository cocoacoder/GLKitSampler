//
//  PFViewController.m
//  OpenGL Game
//
//  Created by Jim Hillhouse on 2/1/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import "PFGLKitSample1ViewController.h"

#import <CoreMotion/CoreMotion.h>

//#import "drawglobe.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))


//
// This is for the sphere. This and the sphere generation code will be moved shortly to it's own
// code.
//
#define THETA_STEPS 60
#define PHI_STEPS	60
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




//GLfloat gCubeVertexData[216] = 
//
// three x, y, z coordinates
// three bytes per coordinate
// six vertices per face
// six faces per cube
/*
GLfloat gCubeVertexData[(3 + 3 + 2) * 4 * 6 * 6] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ, texCoord0S, texCoord0T
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,        0.0, 0.0,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,        1.0, 0.0,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,        0.0, 1.0,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,        0.0, 1.0,
    0.5f, 0.5f, 0.5f,          1.0f, 0.0f, 0.0f,        1.0, 1.0,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,        1.0, 0.0,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,        1.0, 0.0,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,        0.0, 0.0,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,        1.0, 1.0,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,        1.0, 1.0,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,        0.0, 0.0,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,        0.0, 1.0,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,       1.0, 0.0,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,       0.0, 0.0,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,       1.0, 1.0,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,       1.0, 1.0,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,       0.0, 0.0,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,       0.0, 1.0,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,       0.0, 0.0,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,       1.0, 0.0,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,       0.0, 1.0,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,       0.0, 1.0,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,       1.0, 0.0,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,       1.0, 1.0,
    
//    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
//    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
//    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
//    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
//    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
//    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, 0.5f, 0.5f,          0.577f, 0.577f, 0.577f,  1.0, 1.0,
    -0.5f, 0.5f, 0.5f,         0.577f, 0.577f, 0.577f,  0.0, 1.0,
    0.5f, -0.5f, 0.5f,         0.577f, 0.577f, 0.577f,  1.0, 0.0,
    0.5f, -0.5f, 0.5f,         0.577f, 0.577f, 0.577f,  1.0, 0.0,
    -0.5f, 0.5f, 0.5f,         0.577f, 0.577f, 0.577f,  0.0, 1.0,
    -0.5f, -0.5f, 0.5f,        0.577f, 0.577f, 0.577f,  0.0, 0.0,

    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,       1.0, 0.0,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,       0.0, 0.0,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,       1.0, 1.0,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,       1.0, 1.0,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,       0.0, 0.0,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f,       0.0, 1.0,
};
*/
/*
GLfloat gCubeVertexData[(3 + 2) * 6 * 6] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ, texCoord0S, texCoord0T
    0.5f, -0.5f, -0.5f,     0.0, 0.0,
    0.5f, 0.5f, -0.5f,      1.0, 0.0,
    0.5f, -0.5f, 0.5f,      0.0, 1.0,
    0.5f, -0.5f, 0.5f,      0.0, 1.0,
    0.5f, 0.5f, 0.5f,       1.0, 1.0,
    0.5f, 0.5f, -0.5f,      1.0, 0.0,
    
    0.5f, 0.5f, -0.5f,      1.0, 0.0,
    -0.5f, 0.5f, -0.5f,     0.0, 0.0,
    0.5f, 0.5f, 0.5f,       1.0, 1.0,
    0.5f, 0.5f, 0.5f,       1.0, 1.0,
    -0.5f, 0.5f, -0.5f,     0.0, 0.0,
    -0.5f, 0.5f, 0.5f,      0.0, 1.0,
    
    -0.5f, 0.5f, -0.5f,     1.0, 0.0,
    -0.5f, -0.5f, -0.5f,    0.0, 0.0,
    -0.5f, 0.5f, 0.5f,      1.0, 1.0,
    -0.5f, 0.5f, 0.5f,      1.0, 1.0,
    -0.5f, -0.5f, -0.5f,    0.0, 0.0,
    -0.5f, -0.5f, 0.5f,     0.0, 1.0,
    
    -0.5f, -0.5f, -0.5f,    0.0, 0.0,
    0.5f, -0.5f, -0.5f,     1.0, 0.0,
    -0.5f, -0.5f, 0.5f,     0.0, 1.0,
    -0.5f, -0.5f, 0.5f,     0.0, 1.0,
    0.5f, -0.5f, -0.5f,     1.0, 0.0,
    0.5f, -0.5f, 0.5f,      1.0, 1.0,
    
    0.5f, 0.5f, 0.5f,       1.0, 1.0,
    -0.5f, 0.5f, 0.5f,      0.0, 1.0,
    0.5f, -0.5f, 0.5f,      1.0, 0.0,
    0.5f, -0.5f, 0.5f,      1.0, 0.0,
    -0.5f, 0.5f, 0.5f,      0.0, 1.0,
    -0.5f, -0.5f, 0.5f,     0.0, 0.0,
    
    0.5f, -0.5f, -0.5f,     1.0, 0.0,
    -0.5f, -0.5f, -0.5f,    0.0, 0.0,
    0.5f, 0.5f, -0.5f,      1.0, 1.0,
    0.5f, 0.5f, -0.5f,      1.0, 1.0,
    -0.5f, -0.5f, -0.5f,    0.0, 0.0,
    -0.5f, 0.5f, -0.5f,     0.0, 1.0     
};
*/
/*
GLfloat gCubeVertexData[(3) * 6 * 6] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ
    0.5f, -0.5f, -0.5f,     
    0.5f, 0.5f, -0.5f,      
    0.5f, -0.5f, 0.5f,      
    0.5f, -0.5f, 0.5f,      
    0.5f, 0.5f, 0.5f,       
    0.5f, 0.5f, -0.5f,      
    
    0.5f, 0.5f, -0.5f,      
    -0.5f, 0.5f, -0.5f,     
    0.5f, 0.5f, 0.5f,       
    0.5f, 0.5f, 0.5f,       
    -0.5f, 0.5f, -0.5f,     
    -0.5f, 0.5f, 0.5f,      
    
    -0.5f, 0.5f, -0.5f,     
    -0.5f, -0.5f, -0.5f,    
    -0.5f, 0.5f, 0.5f,      
    -0.5f, 0.5f, 0.5f,      
    -0.5f, -0.5f, -0.5f,    
    -0.5f, -0.5f, 0.5f,     
    
    -0.5f, -0.5f, -0.5f,    
    0.5f, -0.5f, -0.5f,     
    -0.5f, -0.5f, 0.5f,     
    -0.5f, -0.5f, 0.5f,     
    0.5f, -0.5f, -0.5f,     
    0.5f, -0.5f, 0.5f,      
    
    //    0.5f, 0.5f, 0.5f, 
    //    -0.5f, 0.5f, 0.5f,
    //    0.5f, -0.5f, 0.5f,
    //    0.5f, -0.5f, 0.5f,
    //    -0.5f, 0.5f, 0.5f,
    //    -0.5f, -0.5f, 0.5f
    
    0.5f, 0.5f, 0.5f,       
    -0.5f, 0.5f, 0.5f,      
    0.5f, -0.5f, 0.5f,      
    0.5f, -0.5f, 0.5f,      
    -0.5f, 0.5f, 0.5f,      
    -0.5f, -0.5f, 0.5f,     
    
    0.5f, -0.5f, -0.5f,     
    -0.5f, -0.5f, -0.5f,    
    0.5f, 0.5f, -0.5f,      
    0.5f, 0.5f, -0.5f,      
    -0.5f, -0.5f, -0.5f,    
    -0.5f, 0.5f, -0.5f         
};
*/
/*
GLfloat gCubeVertexData[(3) * 17] =
{
    -1,  1,  1, // Strip 1
     1,  1,  1,
    -1, -1,  1, // Strip 2
     1, -1,  1,
    -1, -1, -1, // Strip 3
     1, -1, -1,
    -1,  1, -1, // Strip 4
     1,  1, -1,
    -1,  1,  1, // Strip 5
     1,  1,  1,
     1, -1,  1, // Strip 6
     1,  1, -1,
     1, -1, -1, // Strip 7
    -1, -1, -1,
    -1,  1, -1, // Strip 8
    -1, -1,  1,
    -1,  1,  1,
};
*/

GLfloat gCubeVertexData[(3) * 4] = 
{
    -1,  1,  1,
    -1, -1,  1,
     1, -1,  1,
     1,  1,  1,
};






@interface PFGLKitSample1ViewController () <UIGestureRecognizerDelegate>
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


}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
//@property (strong, nonatomic) GLKReflectionMapEffect *effect;
@property (strong, nonatomic) GLKSkyboxEffect *skybox;

@property (strong, nonatomic) CMAttitude *referenceFrame;

- (void)createSphere;

- (void)setupGL;
- (void)tearDownGL;

@end




@implementation PFGLKitSample1ViewController



@synthesize pitchLabel  = _pitchLabel;
@synthesize rollLabel   = _rollLabel;

@synthesize context = _context;
@synthesize effect = _effect;
@synthesize skybox = _skybox;

@synthesize referenceFrame = _referenceFrame;

//@synthesize delegate = _delegate;



#pragma mark - View Life

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    
    // This generates the sphere
//    generateGlobeVertexArrays();

    
    [self setupGL];
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}



# pragma mark - Sphere Generation Code

- (void)createSphere
{
//    GLfloat globeVertices[ARRAY_LENGTH][3];
//    GLushort globeIndices[INDEX_LENGTH];
    
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
    //    self.effect               = [[GLKReflectionMapEffect alloc] init];
    self.effect.light0.enabled  = GL_TRUE;
//    self.effect.light0.spotCutoff = 180.0;
    
    GLfloat ambientColor    = 0.20f;
    GLfloat alpha = 1.0f;
    self.effect.light0.ambientColor = GLKVector4Make(ambientColor, ambientColor, ambientColor, alpha);
    
    GLfloat diffuseColor    = 0.75f;
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
    
//    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    glBufferData(GL_ARRAY_BUFFER, sizeof(sphereVertices), sphereVertices, GL_STATIC_DRAW);
    
    // Vertices
    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 12, BUFFER_OFFSET(0)); // for model only 
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 20, BUFFER_OFFSET(0)); // for model and texture
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0)); // for model and normals
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0)); // for model, normals, and texture
    
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    //    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12)); // for model and normals only
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12)); // for model, normals, and texture
    
    // Texture
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 20, BUFFER_OFFSET(12)); // for model and texture only
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24)); // for model and texture only
    
    
    glBindVertexArrayOES(0);
    
    // Load the texture for the model
    NSString *texturePath       = [[NSBundle mainBundle] pathForResource:@"Moon_Colored_2048" ofType:@"png"];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:texturePath options:nil error:nil];
    
    self.effect.texture2d0.name = textureInfo.name;
    self.effect.texture2d0.enabled = TRUE;
    
    // Set-up the SkyBox
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
    
    // SkyBox Reflection
//    self.effect.textureCubeMap.name = self.skybox.textureCubeMap.name;
//    self.effect.textureCubeMap.enabled = TRUE;
    
    // Setup Core Motion
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
    baseModelViewMatrix = GLKMatrix4Translate(baseModelViewMatrix, 0.0f, 0.0f, 3.0f);

        
    //
    // Insert Core Motion if avaialble
    //
    if ([_motionMgr isDeviceMotionAvailable]) 
    {
        CMDeviceMotion *motion = [_motionMgr deviceMotion];
        
        
        /*
        //
        // Rotation Matrix
        //
        CMRotationMatrix rotationMatrix = motion.attitude.rotationMatrix;
        CMRotationMatrix rm = rotationMatrix;
        
        // Turn the rotation matrix into a GLK Matrix
        GLKMatrix4 modelViewMatrix = GLKMatrix4Make(rm.m11, rm.m21, rm.m31, 0.0f,
                                                    rm.m12, rm.m22, rm.m32, 0.0f,
                                                    rm.m13, rm.m32, rm.m33, 0.0f,
                                                    0.0f,   0.0f,   0.0f,   1.0f);

//        GLKMatrix4 identity4Matrix = GLKMatrix4Make(1.0f, 0.0f, 0.0f, 0.0f,
//                                                    0.0f, 1.0f, 0.0f, 0.0f,
//                                                    0.0f, 0.0f, 1.0f, 0.0f,
//                                                    0.0f, 0.0f, 0.0f, 1.0f);
        
//        modelViewMatrix = GLKMatrix4Multiply(identity4Matrix, modelViewMatrix);
         */
        
        /*
        //
        // Quaternion
        //
        CMQuaternion quaternionMatrix = motion.attitude.quaternion;
        CMQuaternion qm = quaternionMatrix;
        
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(qm.w, qm.x, qm.y, qm.z);

        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
        */
        
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
        
        
        
        // Update yaw, pitch, and roll labels
        [self.pitchLabel setText:[NSString stringWithFormat:@"%6.2f""°", GLKMathRadiansToDegrees(pitchAngle)]];            
        [self.rollLabel setText:[NSString stringWithFormat:@"%6.2f""°", GLKMathRadiansToDegrees(rollAngle)]];        

    }
    else
    {
        
        //    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
        baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, -M_PI, 1.0f, 1.0f, 1.0f);
        
        // Compute the model view matrix for the object rendered with GLKit
        //    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
        //    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(_rotation, 1.0f, 1.0f, 1.0f);
        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
        
        self.effect.transform.modelviewMatrix = modelViewMatrix;
        
        // Compute the model view matrix for the object rendered with ES2
        //    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
        //    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
        
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
    
    
    //
    // The difference in size from TRIANGLES vs. TRIANGLE_STRIP
    //
    //    glDrawArrays(GL_POINTS, 0, 4); // For line.
    //    glDrawArrays(GL_LINE_LOOP, 0, 4); // For square.
    //    glDrawArrays(GL_TRIANGLE_STRIP, 0, 17); // For cube.
    //    glDrawArrays(GL_TRIANGLES, 0, 36); // cube vertex array.
    //    glDrawArrays(GL_TRIANGLE_STRIP, 0, sizeof(sphereVertices));
    
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



@end
