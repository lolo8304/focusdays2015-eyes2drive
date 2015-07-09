// FaceTracking.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "LuxandFaceSDK.h"

int main(int argc, char* argv[])
{
	if (FSDKE_OK != FSDK_ActivateLibrary("Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M=")){
		MessageBox(0, L"Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)\n", L"Error activating FaceSDK", MB_ICONERROR | MB_OK);
        exit(-1);
    }

	FSDK_Initialize("");
		
	// creating a window
	HWND hwnd = CreateWindowEx(WS_EX_TOOLWINDOW, L"LISTBOX", L"IP Camera Face Tracking", 0, 0, 0, 0, 0, 0, 0, 0, 0); 
	HDC dc = GetDC(hwnd);
	SetWindowPos(hwnd, 0, 0, 0, 660, 540, SWP_NOZORDER|SWP_NOMOVE);
	ShowWindow(hwnd, SW_SHOW);
	RECT ClientRect;
	GetClientRect(hwnd, &ClientRect);
	HPEN hNPen = CreatePen(PS_SOLID, 1, RGB(0, 255, 0));
	HPEN hOPen = (HPEN)SelectObject(dc, hNPen);
	HBRUSH hOldBrush;
	HBRUSH hNewBrush;
	hNewBrush = (HBRUSH)GetStockObject(NULL_BRUSH);
	hOldBrush = (HBRUSH)SelectObject(dc, hNewBrush);

	HFONT myFont = CreateFont(14, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, L"Microsoft Sans Serif");

	// creating input boxes 
	HWND Address = CreateWindow(L"STATIC", L"address:", WS_CHILD, 0, 0, 0, 0, hwnd, 0, 0, 0); 
	SendMessage(Address, WM_SETFONT, (WPARAM)myFont, TRUE);
	SetWindowPos(Address, 0, 5, ClientRect.bottom - 20, 40, 18, SWP_NOZORDER);
	ShowWindow(Address, SW_SHOW);

	HWND AddressBox = CreateWindow(L"EDIT", L"", WS_CHILD | WS_BORDER | ES_AUTOHSCROLL, 0, 0, 0, 0, hwnd, 0, 0, 0); 
	SendMessage(AddressBox, WM_SETFONT, (WPARAM)myFont, TRUE);
	SetWindowPos(AddressBox, 0, 45, ClientRect.bottom - 20, 360, 18, SWP_NOZORDER);
	ShowWindow(AddressBox, SW_SHOW);

	HWND User = CreateWindow(L"STATIC", L"username:", WS_CHILD, 0, 0, 0, 0, hwnd, 0, 0, 0); 
	SendMessage(User, WM_SETFONT, (WPARAM)myFont, TRUE);
	SetWindowPos(User, 0, 410, ClientRect.bottom - 20, 50, 18, SWP_NOZORDER);
	ShowWindow(User, SW_SHOW);

	HWND UserBox = CreateWindow(L"EDIT", L"admin", WS_CHILD | WS_BORDER | ES_AUTOHSCROLL, 0, 0, 0, 0, hwnd, 0, 0, 0); 
	SendMessage(UserBox, WM_SETFONT, (WPARAM)myFont, TRUE);
	SetWindowPos(UserBox, 0, 460, ClientRect.bottom - 20, 65, 18, SWP_NOZORDER);
	ShowWindow(UserBox, SW_SHOW);

	HWND Password = CreateWindow(L"STATIC", L"password:", WS_CHILD, 0, 0, 0, 0, hwnd, 0, 0, 0); 
	SendMessage(Password, WM_SETFONT, (WPARAM)myFont, TRUE);
	SetWindowPos(Password, 0, 530, ClientRect.bottom - 20, 50, 18, SWP_NOZORDER);
	ShowWindow(Password, SW_SHOW);

	HWND PasswordBox = CreateWindow(L"EDIT", L"", WS_CHILD | WS_BORDER | ES_AUTOHSCROLL, 0, 0, 0, 0, hwnd, 0, 0, 0); 
	SendMessage(PasswordBox, WM_SETFONT, (WPARAM)myFont, TRUE);
	SetWindowPos(PasswordBox, 0, 580, ClientRect.bottom - 20, 65, 18, SWP_NOZORDER);
	ShowWindow(PasswordBox, SW_SHOW);

	SendMessage(hwnd, LB_ADDSTRING, 0, (LPARAM)(L"Press Esc to exit ..."));

	// creating a Tracker
	HTracker tracker = 0;
	FSDK_CreateTracker(&tracker);

	int err = 0; // set realtime face detection parameters	
	FSDK_SetTrackerMultipleParameters(tracker, "RecognizeFaces=false; DetectFacialFeatures=true; HandleArbitraryRotations=false; DetermineFaceRotationAngle=false; InternalResizeWidth=256; FaceDetectionThreshold=5;", &err);
						
	int cameraHandle = 0; 
	bool CameraOpened = false;

	MSG msg = {0};
	while (msg.message != WM_QUIT) {
		if (CameraOpened) {
			HImage imageHandle;
			int res = FSDK_GrabFrame(cameraHandle, &imageHandle);			
			if (res != FSDKE_OK) {// grab the current frame from the camera
				printf("error in FSDK_GrabFrame %d\n", res);

				if (PeekMessage(&msg, 0, 0, 0, PM_REMOVE)) {
					TranslateMessage(&msg);   
					DispatchMessage(&msg); 
					if (msg.message == WM_KEYDOWN && msg.wParam == VK_ESCAPE) 
						break;
				}
				continue;
			}
						
			long long IDs[256];
			long long faceCount = 0;
			FSDK_FeedFrame(tracker, 0, imageHandle, &faceCount, IDs, sizeof(IDs));

			HImage resizedImageHandle;
			FSDK_CreateEmptyImage(&resizedImageHandle);

			int width;
			int height;
			FSDK_GetImageWidth(imageHandle, &width);
			FSDK_GetImageHeight(imageHandle, &height);

			float ratio = min(ClientRect.right/(float)width, (ClientRect.bottom - 40)/(float)height);
			FSDK_ResizeImage(imageHandle, ratio, resizedImageHandle);
			FSDK_FreeImage(imageHandle);

			FSDK_GetImageWidth(resizedImageHandle, &width);
			FSDK_GetImageWidth(resizedImageHandle, &height);

			HBITMAP hbitmapHandle; // to store the HBITMAP handle
			FSDK_SaveImageToHBitmap(resizedImageHandle, &hbitmapHandle);

			DrawState(dc, NULL, NULL, (LPARAM)hbitmapHandle, NULL, 0, 16, width, height, DST_BITMAP | DSS_NORMAL);
			
			for (int i = 0; i < faceCount; ++i) {
				TFacePosition facePosition;
				FSDK_GetTrackerFacePosition(tracker, 0, IDs[i], &facePosition);

				int x1 = (int)(ratio*(facePosition.xc - facePosition.w*0.6));
				int y1 = (int)(ratio*(facePosition.yc - facePosition.w*0.5));
				int x2 = (int)(ratio*(facePosition.xc + facePosition.w*0.6));
				int y2 = (int)(ratio*(facePosition.yc + facePosition.w*0.7));
				Rectangle(dc, x1, 16 + y1, x2, 16 + y2);	
			}

			Sleep(20);

			DeleteObject(hbitmapHandle); // delete the HBITMAP object
			FSDK_FreeImage(resizedImageHandle);// delete the FSDK image handle
		}

		if (PeekMessage(&msg, 0, 0, 0, PM_REMOVE)) {
			TranslateMessage(&msg);   
			DispatchMessage(&msg); 
			if (msg.message == WM_KEYDOWN)
			{
				if (msg.wParam == VK_ESCAPE) 
					break;
				if (msg.wParam == VK_RETURN)
				{
					if (CameraOpened && FSDKE_OK != FSDK_CloseVideoCamera(cameraHandle))
					{
						MessageBox(0, L"Error closing camera", L"Error", MB_ICONERROR | MB_OK);
						return -5;
					}
					char Camera_MJPEG_URL[1024];
					SendMessageA(AddressBox, WM_GETTEXT, (WPARAM) 1024, (LPARAM) Camera_MJPEG_URL);
					char username[1024];
					SendMessageA(UserBox, WM_GETTEXT, (WPARAM) 1024, (LPARAM) username);
					char password[1024];
					SendMessageA(PasswordBox, WM_GETTEXT, (WPARAM) 1024, (LPARAM) password);
					int timeout_seconds = 30;

					printf("Trying to open the camera...\n");
					if (FSDKE_OK != FSDK_OpenIPVideoCamera(FSDK_MJPEG, Camera_MJPEG_URL, username, password, timeout_seconds, &cameraHandle)) 
					{ 
						MessageBox(0, L"Error opening IP camera", L"Error", MB_ICONERROR | MB_OK);
						return -2;
					}
					CameraOpened = true;
				}
			}
		} 
	}

	ReleaseDC(hwnd, dc);

	if (CameraOpened && FSDKE_OK != FSDK_CloseVideoCamera(cameraHandle)) {
		MessageBox(0, L"Error closing camera", L"Error", MB_ICONERROR | MB_OK);
        return -5;
	}

	FSDK_Finalize();
	return 0;
}

