/* 
 * transformMultiply.c
 *
 * © Copyright 2017 The MathWorks, Inc.
 */

#include "mex.h"
#include "math.h"

/* The computational routine */
void tranformMultiply(double *a, double *rotMat, double *rotationMatrix)
{
    
    double b[4][4] = {
        {a[0]*rotMat[0] + a[4]*rotMat[1] + a[8]*rotMat[2]  + a[12]*rotMat[3], a[0]*rotMat[4] + a[4]*rotMat[5] + a[8]*rotMat[6]  + a[12]*rotMat[7], a[0]*rotMat[8] + a[4]*rotMat[9] + a[8]*rotMat[10]  + a[12]*rotMat[11], a[0]*rotMat[12] + a[4]*rotMat[13] + a[8]*rotMat[14]  + a[12]*rotMat[15]},
        {a[1]*rotMat[0] + a[5]*rotMat[1] + a[9]*rotMat[2]  + a[13]*rotMat[3], a[1]*rotMat[4] + a[5]*rotMat[5] + a[9]*rotMat[6]  + a[13]*rotMat[7], a[1]*rotMat[8] + a[5]*rotMat[9] + a[9]*rotMat[10]  + a[13]*rotMat[11], a[1]*rotMat[12] + a[5]*rotMat[13] + a[9]*rotMat[14]  + a[13]*rotMat[15]},
        {a[2]*rotMat[0] + a[6]*rotMat[1] + a[10]*rotMat[2] + a[14]*rotMat[3], a[2]*rotMat[4] + a[6]*rotMat[5] + a[10]*rotMat[6] + a[14]*rotMat[7], a[2]*rotMat[8] + a[6]*rotMat[9] + a[10]*rotMat[10] + a[14]*rotMat[11], a[2]*rotMat[12] + a[6]*rotMat[13] + a[10]*rotMat[14] + a[14]*rotMat[15]},
        {a[3]*rotMat[0] + a[7]*rotMat[1] + a[11]*rotMat[2] + a[15]*rotMat[3], a[3]*rotMat[4] + a[7]*rotMat[5] + a[11]*rotMat[6] + a[15]*rotMat[7], a[3]*rotMat[8] + a[7]*rotMat[9] + a[11]*rotMat[10] + a[15]*rotMat[11], a[3]*rotMat[12] + a[7]*rotMat[13] + a[11]*rotMat[14] + a[15]*rotMat[15]}
    };

    int MATLABIdx[16] = {0,4,8,12, 1,5,9,13, 2,6,10,14, 3,7,11,15};
    int i = 0;
    int j = 0;
    for( i=0; i < 4; i++ ) {
        for( j=0; j < 4; j++ ) {
            rotationMatrix[MATLABIdx[i*4+j]] = b[i][j];
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
   tranformMultiply(inU, inV, outMatrix);
}
