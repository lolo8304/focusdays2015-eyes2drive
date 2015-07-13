
// scans the database and finds a best match for the photo passed from the
// command line
#include <stdio.h>
#include <string.h>
#include <iostream>
#include <sys/stat.h>
#include "LuxandFaceSDK.h"

using namespace std;

#define DatabaseFilename "faces.db"

struct TFaceRecord
{
	char filename[1024];
	FSDK_FaceTemplate FaceTemplate; //Face Template;
};

void SortList(char * List, float * Scores, int l, int r)
{
    int i = l;
    int j = r;
    float x = Scores[(i + j)/2];
    do
	{
        while (Scores[i] > x) i++;
        while (Scores[j] < x) j--;
        if (i <= j)
		{
			char s[1024];
			strncpy(s, List + i * 1024, 1024);
			strncpy(List + i * 1024, List + j * 1024, 1024);
			strncpy(List + j * 1024, s, 1024);

			float t = Scores[i];
			Scores[i] = Scores[j];
			Scores[j] = t;

			i++;
			j--;
		}
	}
    while (i < j);
    if (j > l) SortList(List, Scores, l, j);
    if (i < r) SortList(List, Scores, i, r);
}

int main(int argc, char * argv[])
{
	if (argc == 1)
	{
		cerr << "Please specify a file name" << endl;
		return -1;
	}

	TFaceRecord face;
	string FullPath(argv[1]);
	int FileNameStart = FullPath.find_last_of('\\');
	strncpy(face.filename, argv[1]+FileNameStart+1, 1024);

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
	int DatabasePathEnd = DatabaseFullPath.find_last_of('\\');
	
	char fname[1024];
	strncpy(fname, argv[0], DatabasePathEnd+1);
	strncpy(fname + DatabasePathEnd+1, DatabaseFilename, 1023 - DatabasePathEnd);

	FILE * f = fopen(fname, "rb");

	if (!f)
	{
		cerr << "Database not exists" << endl;
		return -1;
	}


	struct stat st;
	stat(fname, &st);
	int BaseSize = st.st_size / sizeof(TFaceRecord);

	float * values = new float[BaseSize];
	char * names = new char[BaseSize * 1024];

	for (int k=0; k<BaseSize; k++)
	{
		TFaceRecord face1;
		fread(&face1, sizeof(face1), 1, f);
		FSDK_MatchFaces(&face1.FaceTemplate, &face.FaceTemplate, &(values[k]));
		strncpy(names + k * 1024, face1.filename, 1024);
	}

	SortList(names, values, 0, BaseSize-1);

	for (int i = 0; i < min(20, BaseSize); i++)
	{
		char similarity[10];
		sprintf(similarity, "%f", values[i]);
		cout << similarity << " " << names + i * 1024 << endl;
	}
	delete values;
	delete names;
	fclose(f);
	return 0;
}

