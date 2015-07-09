// FacialFeatures.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "LuxandFaceSDK.h"

int _tmain(int argc, _TCHAR* argv[])
{
    if (FSDKE_OK != FSDK_ActivateLibrary("Jl3R1DBC1qVQonaiBAq8gK7KzetXbFb4r+OF1DLzInT3KyXHvgHNLyk2Tymk5G6GBv58/Oqn+SQeOWCQfQASTV1Mcd7RQAsrmW02oOa9lhZsMockPLoEnpsH4W1I0+zmxmUwecWKEep9j4BrYhQWuiA3QcNeQO+tfyLOHASk3+M=")) {
		MessageBox(0, L"Please run the License Key Wizard (Start - Luxand - FaceSDK - License Key Wizard)\n", L"Error activating FaceSDK", MB_ICONERROR | MB_OK);
        exit(-1);
    }

	FSDK_Initialize("");
	FSDK_SetFaceDetectionParameters(true, true, 256);
	FSDK_SetFaceDetectionThreshold(3);

	HWND hwnd = CreateWindowEx(WS_EX_TOOLWINDOW, L"LISTBOX", L"Facial Features", 0, 0, 0, 0, 0, 0, 0, 0, 0); 
	HDC dc = GetDC(hwnd);
	SetWindowPos(hwnd, 0, 0, 0, 646, 518, SWP_NOZORDER|SWP_NOMOVE);
	ShowWindow(hwnd, SW_SHOW);

	RECT ClientRect;
	GetClientRect(hwnd, &ClientRect);

	HPEN FaceRectanglePen = CreatePen(PS_SOLID, 1, RGB(0, 255, 0));
	HBRUSH FaceRectangleBrush = (HBRUSH)GetStockObject(NULL_BRUSH);

	HPEN FeatureCirclesPen = CreatePen(PS_SOLID, 1, RGB(0, 0, 255));
	LOGBRUSH brush;
	brush.lbColor = RGB(0, 0, 255);
	brush.lbStyle = BS_SOLID;
	HBRUSH FeatureCirclesBrush = CreateBrushIndirect(&brush);

	SendMessage(hwnd, LB_ADDSTRING, 0, (LPARAM)(L"Press Enter to open image, press Esc to exit ...")); 
	
	TFacePosition facePosition;
	FSDK_Features facialFeatures;
					
	MSG msg = {0};

	bool ImageOpened = false;
	int FaceDetected = -1;

	int width, height;

	HImage ResizedImageHandle;
	FSDK_CreateEmptyImage(&ResizedImageHandle);

	while(msg.message != WM_QUIT)
		if (PeekMessage(&msg, 0, 0, 0, PM_REMOVE))
		{
			TranslateMessage(&msg);   
			DispatchMessage(&msg); 
			if (msg.message == WM_KEYDOWN && msg.wParam == VK_ESCAPE) 
				break;

			if (msg.message == WM_KEYDOWN && msg.wParam == VK_RETURN)
			{
				HImage imageHandle;
				OPENFILENAMEA oFile;
				char szPath[MAX_PATH];
				char szDir[MAX_PATH];
				ZeroMemory(&oFile, sizeof(oFile));
				GetCurrentDirectoryA(sizeof(szDir), szDir);
				lstrcpyA(szPath, "");
				oFile.lStructSize       = sizeof(oFile);
				oFile.hwndOwner         = hwnd;
				oFile.hInstance         = NULL;
				oFile.lpstrFilter       = "Images(*.jpg;*.jpeg;*.jpe;*.jfif;*.bmp;*.png)\0*.jpg;*.jpeg;*.jpe;*.jfif;*.bmp;*.png\0\0";
				oFile.lpstrFile         = szPath;
				oFile.nMaxFile          = sizeof(szPath);
				oFile.lpstrInitialDir   = szDir;
				oFile.Flags = OFN_FILEMUSTEXIST | OFN_HIDEREADONLY;
				oFile.lpstrDefExt = NULL;
				if (GetOpenFileNameA(&oFile) && FSDKE_OK == FSDK_LoadImageFromFile(&imageHandle, oFile.lpstrFile))
				{
					FaceDetected = FSDK_DetectFace(imageHandle, &facePosition);
					if (FaceDetected == FSDKE_OK )
						FSDK_DetectFacialFeaturesInRegion(imageHandle, &facePosition, &facialFeatures);

					FSDK_GetImageWidth(imageHandle, &width);
					FSDK_GetImageHeight(imageHandle, &height);
					double resizeCoefficient = min(ClientRect.right/(double)width, (ClientRect.bottom - 16)/(double)height);

					FSDK_FreeImage(ResizedImageHandle);
					FSDK_CreateEmptyImage(&ResizedImageHandle);
					FSDK_ResizeImage(imageHandle, resizeCoefficient, ResizedImageHandle);

					FSDK_GetImageWidth(ResizedImageHandle, &width);
					FSDK_GetImageHeight(ResizedImageHandle, &height);

					FSDK_FreeImage(imageHandle);// delete the FSDK image handle
					
					if ( FaceDetected == FSDKE_OK )
					{
						facePosition.xc = (int)(resizeCoefficient * facePosition.xc);
						facePosition.yc = (int)(resizeCoefficient * facePosition.yc);
						facePosition.w = (int)(resizeCoefficient * facePosition.w);
						for (int i = 0; i < FSDK_FACIAL_FEATURE_COUNT; i++)
						{
							facialFeatures[i].x = (int)(resizeCoefficient * facialFeatures[i].x);
							facialFeatures[i].y = (int)(resizeCoefficient * facialFeatures[i].y);
						}
					}

					ImageOpened = true;
					InvalidateRect(hwnd, NULL, TRUE);
				}
			}

			if (msg.message == WM_MOVE)
				InvalidateRect(hwnd, NULL, TRUE);

			if (msg.message == WM_PAINT && ImageOpened )
			{
				HBITMAP hbitmapHandle; // to store the HBITMAP handle
				FSDK_SaveImageToHBitmap(ResizedImageHandle, &hbitmapHandle);
				DrawState(dc, NULL, NULL, (LPARAM)hbitmapHandle, NULL, (ClientRect.right - width)/2, 8 + (ClientRect.bottom - height)/2, width, height, DST_BITMAP | DSS_NORMAL);
				DeleteObject(hbitmapHandle); // delete the HBITMAP object

				if (FaceDetected == FSDKE_OK)
				{
					int left = min(width - 1, max(0, facePosition.xc - (int)(facePosition.w*0.6))) + (ClientRect.right - width)/2;
					int right = min(width - 1, max(0, facePosition.xc + (int)(facePosition.w*0.6))) + (ClientRect.right - width)/2;
					int top = min(height - 1, max(0, facePosition.yc - (int)(facePosition.w*0.5))) + 8 + (ClientRect.bottom - height)/2;
					int bottom = min(height - 1, max(0, facePosition.yc + (int)(facePosition.w*0.7))) + 8 + (ClientRect.bottom - height)/2;
					SelectObject(dc, FaceRectanglePen);
					SelectObject(dc, FaceRectangleBrush);
					Rectangle(dc, left, top, right, bottom);

					SelectObject(dc, FeatureCirclesPen);
					SelectObject(dc, FeatureCirclesBrush);
					for (int i = 0; i < FSDK_FACIAL_FEATURE_COUNT; i++)
						Ellipse(dc, min(width - 1, max(0, facialFeatures[i].x - 2)) + (ClientRect.right - width)/2,
									min(height - 1, max(0, facialFeatures[i].y - 2)) + 8 + (ClientRect.bottom - height)/2,
									min(width - 1, max(0, facialFeatures[i].x + 2)) + (ClientRect.right - width)/2,
									min(height - 1, max(0, facialFeatures[i].y + 2)) + 8 + (ClientRect.bottom - height)/2);
				}
			}
		}
	FSDK_FreeImage(ResizedImageHandle);// delete the FSDK resized image handle
	ReleaseDC(hwnd, dc);

	FSDK_Finalize();
	return 0;
}

