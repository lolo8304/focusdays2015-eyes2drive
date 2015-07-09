
// adds single photo to a database

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <iostream>
#include "LuxandFaceSDK.h"

using namespace std;

#define DatabaseFilename "faces.db"

#if defined( _WIN32 ) || defined ( _WIN64 )
	const char FilePathDirectorySeparator = '\\';
#else
	const char FilePathDirectorySeparator = '/';
#endif

struct TFaceRecord
{
	char filename[1024];
	FSDK_FaceTemplate FaceTemplate; //Face Template;
};

int main(int argc, char * argv[])
{
	if (argc == 1)
	{
		cerr << "Please specify a file name" << endl;
		return -1;
	}
	TFaceRecord face;
	string FullPath(argv[1]);
	int FileNameStart = FullPath.find_last_of(FilePathDirectorySeparator);
	strcpy(face.filename, argv[1]+FileNameStart+1);

	if (FSDK_ActivateLibrary("Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M=")  != FSDKE_OK)
	{
		cerr << "Error activating FaceSDK" << endl;
		cerr << "Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)" << endl;
		return -1;
	}	
	FSDK_Initialize("");
	
	HImage ImageHandle;
	if (FSDK_LoadImageFromFile(&ImageHandle, argv[1]) != FSDKE_OK)
	{
		cerr << "Error loading file" << endl;
		return -1;
	}

	//Assuming that faces are vertical (HandleArbitraryRotations = false) to speed up face detection
	FSDK_SetFaceDetectionParameters(false, true, 384);
    FSDK_SetFaceDetectionThreshold(3);
	int r = FSDK_GetFaceTemplate(ImageHandle, &face.FaceTemplate);
	FSDK_FreeImage(ImageHandle);

	if (r != FSDKE_OK)
	{
		cerr << "Error detecting face" << endl;
		return -1;
	}

	string DatabaseFullPath(argv[0]);
	int DatabasePathEnd = DatabaseFullPath.find_last_of(FilePathDirectorySeparator);
	
	char fname[1024];
	memset(fname, 0, 1024);
	strncpy(fname, argv[0], DatabasePathEnd+1);
	strcpy(fname + DatabasePathEnd+1, DatabaseFilename);

	FILE * f = fopen(fname, "ab");

	fwrite(&face, sizeof(face), 1, f);

	fclose(f);
	return 0;
}

