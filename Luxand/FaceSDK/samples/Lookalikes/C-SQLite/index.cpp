
// adds single photo to a database

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <iostream>
#include "sqlite3.h"
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


void DatabaseError(sqlite3 * db){
	int errcode = sqlite3_errcode(db);
	const char *errmsg = sqlite3_errmsg(db);
	fprintf(stderr, "Database error %d: %s\n", errcode, errmsg);
}

int CreateFacesTable(sqlite3 * db){
	const char * sqlCmd = "CREATE TABLE FaceList (filename TEXT PRIMARY KEY, FaceTemplate BLOB)";
	return sqlite3_exec(db, sqlCmd, 0, 0, 0);
}

int SaveFaceInDB(sqlite3 * db, TFaceRecord & fr){
	const char *sqlCmd = "INSERT INTO FaceList (filename, FaceTemplate) VALUES(?, ?)";
	sqlite3_stmt *stmt;
	int rc;

	do {
		rc = sqlite3_prepare(db, sqlCmd, -1, &stmt, 0); 
		if( rc != SQLITE_OK ){
			return rc;
		}
		sqlite3_bind_text(stmt, 1, (const char *)fr.filename, -1, SQLITE_STATIC);
		sqlite3_bind_blob(stmt, 2, (const unsigned char *)&fr.FaceTemplate, sizeof(FSDK_FaceTemplate), SQLITE_STATIC);
		sqlite3_step(stmt);
		rc = sqlite3_finalize(stmt); 
	} while( rc==SQLITE_SCHEMA ); // if sqlite3_finalize() returned SQLITE_SCHEMA, then try to execute the statement again.

	return rc;
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


	sqlite3 *db;     
	sqlite3_open(fname, &db);
	if( SQLITE_OK!=sqlite3_errcode(db) ){
		DatabaseError(db);
		return -1;
	}

	CreateFacesTable(db); //create the faces table if it has not already been created
	
	if( SQLITE_OK != SaveFaceInDB(db, face) ){
		DatabaseError(db);
		return -1;
	}
	
	sqlite3_close(db);
	cout << "stored in " << fname << endl; 

	return 0;
}

