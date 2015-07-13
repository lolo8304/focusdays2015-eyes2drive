// FaceTracking.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "resource.h"
#include "LuxandFaceSDK.h"

LRESULT CALLBACK	WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK	InputName(HWND, UINT, WPARAM, LPARAM);

const char * TrackerMemoryFile = "tracker.dat";

// whether we recognize faces, or user has clicked a face
enum ProgramState {psRecognize, psRemember};
ProgramState programState;
bool NeedClose;

long long IDs[256]; // detected faces
long long faceCount = 0;

RECT faceRects[256]; 
int MouseX = 0;
int MouseY = 0;

char userName[1024];

wchar_t ** CameraList;
int CameraCount = 0;

FSDK_VideoFormatInfo * VideoFormatList = 0;
int VideoFormatCount = 0;

int OpenCamera(int & cameraHandle, int & width, int & height, int & bitsPerPixel) {
	printf("Getting camera list...\n");

    if (0 == FSDK_GetCameraList(&CameraList, &CameraCount))
		for (int i = 0; i < CameraCount; i++) 
			wprintf(L"camera: %s\n", CameraList[i]);

	if (0 == CameraCount) {
		MessageBox(0, L"Please attach a camera", L"Error", MB_ICONERROR | MB_OK);
        return -1;
    }

	int CameraIdx = 0; // choose the first camera
	FSDK_GetVideoFormatList(CameraList[CameraIdx], &VideoFormatList, &VideoFormatCount);

	for (int i = 0; i < VideoFormatCount ; i++) 
		printf("format %d: %dx%d, %d bpp\n", i, VideoFormatList[i].Width, VideoFormatList[i].Height, VideoFormatList[i].BPP);

	int VideoFormat = 0; // choose a video format
	width = VideoFormatList[VideoFormat].Width;
	height = VideoFormatList[VideoFormat].Height;
	bitsPerPixel = VideoFormatList[VideoFormat].BPP;
	FSDK_SetVideoFormat(CameraList[0], VideoFormatList[VideoFormat]);

	printf("Trying to open the first camera...\n");
	cameraHandle = 0;
	if (FSDKE_OK != FSDK_OpenVideoCamera(CameraList[0], &cameraHandle)) { 
		MessageBox(0, L"Error opening the first camera", L"Error", MB_ICONERROR | MB_OK);
        return -2;
	} 
	return 0;
}

int InitializeWindow(int width, int height, HDC & dc, HWND & hwnd, HWND & TextBox) {
	LOGBRUSH brush;
	brush.lbColor = RGB(230, 230, 230);
	brush.lbStyle = BS_SOLID;
	HBRUSH bBrush;
	bBrush=CreateBrushIndirect(&brush);
	WNDCLASSEX wcex;
	wcex.cbSize = sizeof(WNDCLASSEX);
	wcex.style			= 0;
	wcex.lpfnWndProc	= WndProc;
	wcex.cbClsExtra		= 0;
	wcex.cbWndExtra		= 0;
	wcex.hInstance		= 0;
	wcex.hIcon			= 0;
	wcex.hCursor		= LoadCursor(NULL, IDC_ARROW);
	wcex.hbrBackground	= bBrush;
	wcex.lpszMenuName	= 0;
	wcex.lpszClassName	= L"My Window Class";
	wcex.hIconSm		= 0;
	RegisterClassEx(&wcex);

	hwnd = CreateWindowEx(WS_EX_TOOLWINDOW, L"My Window Class", L"Live Recognition", WS_SYSMENU, 0, 0, 0, 0, 0, 0, 0, 0); 
	dc = GetDC(hwnd);
	SetWindowPos(hwnd, 0, 0, 0, 6+width, 6+16+(height)+60, SWP_NOZORDER|SWP_NOMOVE);
	ShowWindow(hwnd, SW_SHOW);
	HPEN hNPen = CreatePen(PS_SOLID, 1, RGB(0, 255, 0));
	HPEN hOPen = (HPEN)SelectObject(dc, hNPen);
	HBRUSH hOldBrush;
	HBRUSH hNewBrush;
	hNewBrush = (HBRUSH)GetStockObject(NULL_BRUSH);
	hOldBrush = (HBRUSH)SelectObject(dc, hNewBrush);

	UpdateWindow(hwnd);
	TextBox = CreateWindow(L"Static", L"Click face to name it", SS_CENTER | WS_CHILD, 0, 0, 0, 0, hwnd, 0, 0, 0);
	HFONT MyFont = CreateFont(25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, L"Microsoft Sans Serif");
	SendMessage(TextBox, WM_SETFONT, WPARAM(MyFont), TRUE);
	SetWindowPos(TextBox, 0, 3+width/2-width, height+10, 2*width, 40, SWP_NOZORDER);
	ShowWindow(TextBox, SW_SHOW);
	UpdateWindow(hwnd);
	return 0;
}

int GetSelectedRectangle() {
	int RectSelected = -1;
	for (int i = 0; i < faceCount; i++) 
		if (MouseX >= faceRects[i].left && MouseX <= faceRects[i].right && 
			MouseY >= faceRects[i].top && MouseY <= faceRects[i].bottom) 
		{
			RectSelected = i;
			break;
		}
	
	if (RectSelected >= 0) {
		HCURSOR Cur = LoadCursor(NULL, IDC_HAND);
		SetCursor(Cur);
	}
	return RectSelected;
}

void DisplayImage(HDC dc, HImage imageHandle) {	
	int width = 0; 
	int height = 0;
	FSDK_GetImageWidth(imageHandle, &width);
	FSDK_GetImageHeight(imageHandle, &height);
	HBITMAP hbitmapHandle; // to store the HBITMAP handle
	FSDK_SaveImageToHBitmap(imageHandle, &hbitmapHandle);
	DrawState(dc, NULL, NULL, (LPARAM)hbitmapHandle, NULL, 0, 0, width, height, DST_BITMAP | DSS_NORMAL);		
	DeleteObject(hbitmapHandle); // delete the HBITMAP object
}

void DisplayText(HDC dc, char * name, RECT r) {
	SetBkMode(dc, TRANSPARENT);
	SetTextColor(dc, RGB(0, 255, 0));
	HFONT MyFont = CreateFont(25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, L"Microsoft Sans Serif");
	SelectObject(dc, MyFont);
	DrawTextA(dc, name, -1, &r, DT_CENTER);
	DeleteObject(MyFont);
}

int _tmain(int argc, _TCHAR* argv[])
{
    if (FSDKE_OK != FSDK_ActivateLibrary("Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M=")) {
		MessageBox(0, L"Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)\n", L"Error activating FaceSDK", MB_ICONERROR | MB_OK);
        exit(-1);
    }

	FSDK_Initialize("");
	FSDK_InitializeCapturing();

	int cameraHandle = 0;
	int width, height, bitsPerPixel;
	int res = OpenCamera(cameraHandle, width, height, bitsPerPixel);
	if (res < 0) return res;

	// creating a Tracker
	HTracker tracker = 0;
	if (0 != FSDK_LoadTrackerMemoryFromFile(&tracker, TrackerMemoryFile)) // try to load saved tracker state
		FSDK_CreateTracker(&tracker); // if could not be loaded, create a new tracker

	int err = 0; // set realtime face detection parameters
	FSDK_SetTrackerMultipleParameters(tracker, "HandleArbitraryRotations=false; DetermineFaceRotationAngle=false; InternalResizeWidth=100; FaceDetectionThreshold=5;", &err);

	HDC dc;
	HWND hwnd, TextBox;
	InitializeWindow(width, height, dc, hwnd, TextBox);
					
	MSG msg = {0};
	NeedClose = FALSE;
	programState = psRecognize;	

	while (msg.message != WM_QUIT) {
		HImage imageHandle;
		FSDK_GrabFrame(cameraHandle, &imageHandle); // receive a frame from the camera
		FSDK_FeedFrame(tracker, 0, imageHandle, &faceCount, IDs, sizeof(IDs));
		DisplayImage(dc, imageHandle);
	
		for (int i = 0; i < faceCount; i++) {
			TFacePosition facePosition;
			FSDK_GetTrackerFacePosition(tracker, 0, IDs[i], &facePosition);

			faceRects[i].left = facePosition.xc - (int)(facePosition.w*0.6);
			faceRects[i].top = min(height, facePosition.yc - (int)(facePosition.w*0.5));
			faceRects[i].right = facePosition.xc + (int)(facePosition.w*0.6);
			faceRects[i].bottom = min(height, facePosition.yc + (int)(facePosition.w*0.7));
			Rectangle(dc, faceRects[i].left, faceRects[i].top, faceRects[i].right, faceRects[i].bottom);	

			char name[1024];
			int res = FSDK_GetAllNames(tracker, IDs[i], name, sizeof(name));

			if (0 == res && strlen(name) > 0) { // draw name
				RECT NameRect;
				NameRect.left = faceRects[i].left - width;
				NameRect.right = faceRects[i].right + width;
				NameRect.top = min(height, faceRects[i].bottom);
				NameRect.bottom = min(height, faceRects[i].bottom + 30);
				DisplayText(dc, name, NameRect);
			}
		}
		
		// process messages to find if the user clicked on a face
		if (PeekMessage(&msg, 0, 0, 0, PM_REMOVE)) {
			TranslateMessage(&msg);   
			DispatchMessage(&msg); 
			if ((msg.message == WM_KEYDOWN && msg.wParam == VK_ESCAPE) || NeedClose) 
				break;
		} 

		int RectSelected = GetSelectedRectangle(); // find out which face the mouse is over
		if (psRemember == programState && RectSelected >= 0) {
			long long id = IDs[RectSelected];

			if (0 == FSDK_LockID(tracker, id)) {
				strcpy_s(userName, "_noname_");
				// get the user name
				DialogBox(NULL, MAKEINTRESOURCE(IDD_DIALOGINPUTNAME), NULL, InputName);

				if (strcmp(userName, "_noname_") != 0) 
					FSDK_SetName(tracker, IDs[RectSelected], userName);				
				FSDK_UnlockID(tracker, IDs[RectSelected]);
			}
		}
		programState = psRecognize;

		FSDK_FreeImage(imageHandle); // delete the FaceSDK image handle
	}

	ReleaseDC(hwnd, dc);
	FSDK_SaveTrackerMemoryToFile(tracker, TrackerMemoryFile);
	FSDK_FreeTracker(tracker);

	if (FSDKE_OK != FSDK_CloseVideoCamera(cameraHandle)) {
		MessageBox(0, L"Error closing camera", L"Error", MB_ICONERROR | MB_OK);
        return -5;
	}

	FSDK_FreeVideoFormatList(VideoFormatList);
	FSDK_FreeCameraList(CameraList, CameraCount);

	FSDK_FinalizeCapturing();
	FSDK_Finalize();
	return 0;
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message) {
		case WM_MOUSEMOVE:
			MouseX = LOWORD(lParam); 
			MouseY = HIWORD(lParam);			
			return (INT_PTR)TRUE;
	
		case WM_LBUTTONUP:
			programState = psRemember;
			return (INT_PTR)TRUE;	
	
		case WM_CTLCOLORSTATIC:
			SetBkMode((HDC)wParam, TRANSPARENT);
			return (int)CreateSolidBrush(RGB(230, 230, 230));

		case WM_DESTROY:
			NeedClose = TRUE;
			break;
	}
	return DefWindowProc(hWnd, message, wParam, lParam);
}

INT_PTR CALLBACK InputName(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message) {
		case WM_SHOWWINDOW:
			SetFocus(GetDlgItem(hDlg, IDC_EDIT1));
			return (INT_PTR)TRUE;
		break;

		case WM_COMMAND:
			if (LOWORD(wParam) == IDOK) {
				int len = SendDlgItemMessageA(hDlg, IDC_EDIT1, WM_GETTEXT, (WPARAM) sizeof(userName)/2-1, (LPARAM) userName);
				userName[len] = '\0';
				EndDialog(hDlg, LOWORD(wParam));
				return (INT_PTR)TRUE;
			}
			if (LOWORD(wParam) == IDCANCEL) {
				EndDialog(hDlg, LOWORD(wParam));
				return (INT_PTR)TRUE;
			}
		break;
	}
	return (INT_PTR)FALSE;
}