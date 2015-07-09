
// scans the database and finds a best match for the photo passed from the
// command line
#include <stdio.h>
#include <iostream>
#include <sys/stat.h>
#include "sqlite3.h"
#include "LuxandFaceSDK.h"

using namespace std;

#define DatabaseFilename "faces.db"

struct TFaceRecord
{
	char filename[1024];
	FSDK_FaceTemplate FaceTemplate; //Face Template;
};


void DatabaseError(sqlite3 * db){
	int errcode = sqlite3_errcode(db);
	const char *errmsg = sqlite3_errmsg(db);
	fprintf(stderr, "Database error %d: %s\n", errcode, errmsg);
}

bool CountRecords(sqlite3 * db, int * records){
	bool result = false;

	const char *sqlCmd = "SELECT COUNT(*) FROM FaceList";
	sqlite3_stmt *stmt;
	int rc;

	*records = 0;
	do {
		rc = sqlite3_prepare(db, sqlCmd, -1, &stmt, 0);
		if( rc != SQLITE_OK ){
			return false;
		}

		rc = sqlite3_step(stmt);
		if( rc==SQLITE_ROW ){
			*records = sqlite3_column_int(stmt, 0);
			result = true;
		}
		
		rc = sqlite3_finalize(stmt); // Finalize the statement (this releases resources allocated by sqlite3_prepare() )
	} while( rc==SQLITE_SCHEMA ); // If sqlite3_finalize() returned SQLITE_SCHEMA, then try to execute the statement all over again.

	return result;
}

bool MatchWithRecords(sqlite3 *db, float * similarities, char * filenames, FSDK_FaceTemplate & templateToMatch){
	const char *sqlCmd = "SELECT filename, FaceTemplate FROM FaceList";
	sqlite3_stmt *stmt;
	int rc;

	do {
		rc = sqlite3_prepare(db, sqlCmd, -1, &stmt, 0);
		if( rc != SQLITE_OK )
			return false;

		int i = 0;
		while (sqlite3_step(stmt) == SQLITE_ROW){
			int sz = sqlite3_column_bytes(stmt, 0);
			if (sz+1 > 1024){
				cerr << "Error: too long filename found in index file" << endl;
				return false;
			}
			strcpy(filenames + i*1024, (const char *)sqlite3_column_text(stmt, 0));
			
			FSDK_FaceTemplate ft;
			int ts = sqlite3_column_bytes(stmt, 1);
			if (ts != sizeof(FSDK_FaceTemplate)){
				cerr << "Error: wrong data in index file" << endl;
				return false;
			}
			memcpy(&ft, sqlite3_column_blob(stmt, 1), ts);


			if (FSDK_MatchFaces(&ft, &templateToMatch, &(similarities[i])) != FSDKE_OK){
				cerr << "Error matching faces" << endl;
				return false;
			}
			
			++i;
		}
		rc = sqlite3_finalize(stmt); 
	} while( rc==SQLITE_SCHEMA ); // if sqlite3_finalize() returned SQLITE_SCHEMA, then try to execute the statement again.

	return true;
}


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

	sqlite3 *db;     
	sqlite3_open(fname, &db);
	if (SQLITE_OK != sqlite3_errcode(db)){
		DatabaseError(db);
		return -1;
	}
	
	int BaseSize = 0;
	if (CountRecords(db, &BaseSize) && BaseSize){
		float * values = new float[BaseSize];
		char * names = new char[BaseSize * 1024];

		if (MatchWithRecords(db, values, names, face.FaceTemplate)){
			SortList(names, values, 0, BaseSize-1);

			for (int i = 0; i < min(20, BaseSize); i++)
			{
				char similarity[10];
				sprintf(similarity, "%f", values[i]);
				cout << similarity << " " << names + i * 1024 << endl;
			}
		}
		delete values;
		delete names;
	} else {
		cerr << "Please index some faces first" << endl;
		return -1;
	}

	sqlite3_close(db);
	return 0;
}

