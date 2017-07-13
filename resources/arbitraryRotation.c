/* 
 * arbitraryRotation.c
 *
 * Compile this file into a MEX file by typing the following at the MATLAB 
 * command window:
 *
 * >> mex arbitraryRotation.c
 *
 * © Copyright 2017 The MathWorks, Inc.
 */
        
#include "mex.h"
#include "math.h"

#define PI 3.1415926535897932384626433

double vectorNorm(double *a) {

    double norm = 0.0;

    norm = sqrt(a[0]*a[0] + a[1]*a[1] + a[2]*a[2]);
    return norm;
}

double dotProduct(double *u, double *v)
{
    double result = 0.0;

    result = u[0]*v[0] + u[1]*v[1] + u[2]*v[2];
    return result;
}

void normalizeVector(double *u, double *w, double tol) {
    
    double normOfVector = 0.0;

    normOfVector = vectorNorm(u);
    if(normOfVector > tol) {
        w[0] = u[0]/normOfVector;
        w[1] = u[1]/normOfVector;
        w[2] = u[2]/normOfVector;
    }
    else
    {
        w[0] = 0.0;
        w[1] = 0.0;
        w[2] = 0.0;
    }
}

void simpleCross(double *a, double *b, double *c) {
    c[0] = b[2]*a[1] - b[1]*a[2];
    c[1] = b[0]*a[2] - b[2]*a[0];
    c[2] = b[1]*a[0] - b[0]*a[1];
}

int sign(double x) {
    return (x > 0) - (x < 0);
}

/* The computational routine */
void arbitraryRotation(double *u, double *v, double *rotationMatrix)
{

    double tol = 1e-15;
    double uHat[3] = {0,0,0};
    double vHat[3] = {0,0,0};
    normalizeVector(u, uHat, tol);
    normalizeVector(v, vHat, tol);
    
    int i = 0;
    for( i=0; i < 16; i+=5)
        rotationMatrix[i] = 1;

    double rotationAxis[3] = {0,0,0};
    double w[3] = {0,0,0};
    double deltaTheta = 0.0;    
    /* calculate the rotation axis */
    simpleCross(uHat, vHat, rotationAxis);
    if(rotationAxis[0] == 0 & rotationAxis[1] == 0 & rotationAxis[2] == 0) {
        if(sign(uHat[0]) != sign(vHat[0]) | sign(uHat[1]) != sign(vHat[1]) | sign(uHat[2]) != sign(vHat[2])){
            double* axis;
            double x[3] = {1,0,0};
            double y[3] = {0,1,0};
            double z[3] = {0,0,1};
            
            double xProj, yProj, zProj;
            
            xProj = dotProduct(uHat, x);
            yProj = dotProduct(uHat, y);
            zProj = dotProduct(uHat, z);
            if(xProj < yProj){
                if(xProj < zProj)
                    axis = x;
                else
                    axis = z;
            }
            else if(yProj < zProj)
                axis = y;
            else
                axis = z;

            double auDot = dotProduct(axis, uHat);
            rotationAxis[0] = axis[0] - auDot*uHat[0];
            rotationAxis[1] = axis[1] - auDot*uHat[1];
            rotationAxis[2] = axis[2] - auDot*uHat[2];

            normalizeVector(rotationAxis, w, tol);
            /* calculate the angle between the two vectors */
            deltaTheta = PI;
        }
        else
            return;
    }
    else {
        normalizeVector(rotationAxis, w, tol);
        /* calculate the angle between the two vectors */
        deltaTheta = atan2(vectorNorm(rotationAxis), dotProduct(uHat, vHat));
    }

    /* create a rotation matrix */
    double c = 0.0;
    c = cos(deltaTheta);
    double s = 0.0;
    s = sin(deltaTheta);

    double cEye[3][3] = {
        {c, 0, 0},
        {0, c, 0},
        {0, 0, c}
    };

    double wSkew[3][3] = {
        { 0,   -w[2], w[1]},
        { w[2], 0,   -w[0]},
        {-w[1], w[0], 0}
    };

    double wKron[3][3] = {
        { w[0]*w[0], w[1]*w[0], w[2]*w[0]},
        { w[0]*w[1], w[1]*w[1], w[2]*w[1]},
        { w[0]*w[2], w[1]*w[2], w[2]*w[2]}
    };

    int MATLABIdx[9] = {0,4,8, 1,5,9, 2,6,10};
    int j = 0;
    for( i=0; i < 3; i++ ) {
        for( j=0; j < 3; j++ ) {
            rotationMatrix[MATLABIdx[i*3+j]] = cEye[i][j] + (1-c)*wKron[i][j] + s*wSkew[i][j];
        }
    }

    for( i=0; i < 3; i++ ) {
        for( j=0; j < 3; j++ ) {
            if(fabs(rotationMatrix[MATLABIdx[i*3+j]]) < tol)
                rotationMatrix[MATLABIdx[i*3+j]] = 0.0;
        }
    }
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *inU;
    double *inV;
    double *outMatrix;

    /* check for proper number of arguments */
    if(nrhs!=2) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs","Two inputs required.");
    }
    if(nlhs > 1) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs","No more than one output allowed.");
    }
    /* make sure the first input argument is scalar */
    if( !mxIsDouble(prhs[0]) || 
         mxIsComplex(prhs[0])) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notDouble","Input matrix must be type double.");
    }
    
    /* make sure the second input argument is type double */
    if( !mxIsDouble(prhs[1]) || 
         mxIsComplex(prhs[1])) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notDouble","Input matrix must be type double.");
    }

    /* create a pointer to the real data in the input matrix  */
    inU = mxGetPr(prhs[0]);
    inV = mxGetPr(prhs[1]);

    /* create the output matrix */
    plhs[0] = mxCreateDoubleMatrix(4, 4, mxREAL);

    /* get a pointer to the real data in the output matrix */
    outMatrix = mxGetPr(plhs[0]);

    /* call the computational routine */
   arbitraryRotation(inU, inV, outMatrix);
}
