using System;
using System.Collections.Generic;
using System.Text;

namespace Luxand
{
    partial class FSDK
    {
        public class Cam: IDisposable
		{
		    private int camHandle;
            private bool disposed = false;

		    private void CheckForError(int hr){
				if (hr != FSDKE_OK){
					if (hr < FSDKE_OK && hr >= FSDKE_IP_INIT_FAILED)
						throw new Exception("Luxand FaceSDK Error Number " + hr.ToString());
					else
						throw new Exception("System Error Number " + hr.ToString());
				}
			}
		    
            public Cam(ref string CameraName){
				camHandle = -1;
				CheckForError(FSDKCam.OpenVideoCamera(ref CameraName, ref camHandle));
			}
			public Cam(ref string CameraName, FSDKCam.VideoFormatInfo VideoFormat){
				camHandle = -1;
				CheckForError(FSDKCam.SetVideoFormat(ref CameraName, VideoFormat));
				CheckForError(FSDKCam.OpenVideoCamera(ref CameraName, ref camHandle));
			}
			public Cam(FSDKCam.FSDK_VIDEOCOMPRESSIONTYPE CompressionType, string URL, string Username, string Password, int TimeoutSeconds){
				camHandle = -1;
				CheckForError(FSDKCam.OpenIPVideoCamera(CompressionType, URL, Username, Password, TimeoutSeconds, ref camHandle));
			}
		
            public void Dispose(){
                Dispose(true);
                GC.SuppressFinalize(this);
            }
            private void Dispose(bool disposing){
                if (!this.disposed){
                    if (disposing){
                        //dispose managed components
                    }
                    if (camHandle >= 0){
					    FSDKCam.CloseVideoCamera(camHandle);
                        camHandle = -1;
                    }
                }
                disposed = true;
            }
			~Cam(){
                Dispose(false);
			}
			
			
            public CImage GrabFrame(){
				int himage = -1;
				CheckForError(FSDKCam.GrabFrame(camHandle, ref himage));
				return new CImage(himage);
			}
			
		};
    }
}
