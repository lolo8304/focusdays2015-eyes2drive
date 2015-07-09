using System;
using System.Collections.Generic;
using System.Text;

namespace Luxand
{
    partial class FSDK
    {
        public class CImage: IDisposable
        {
            private int hImage, width, height;
            private bool disposed = false;

            private void CheckForError(int hr){
				if (hr != FSDKE_OK){
					throw new Exception("Luxand FaceSDK Error Number " + hr.ToString());
				}
			}
            
            private void PopulateHeightAndWidth(){
				CheckForError(FSDK.GetImageHeight(hImage, ref height));
				CheckForError(FSDK.GetImageWidth(hImage, ref width));
			}
            public void ReloadFromHandle(){
				PopulateHeightAndWidth();
			}
			public int ImageHandle{  //readonly property to access hImage from outside
				get{ return hImage;}
			}	
			public int Height{  //readonly 
				get{ return height;}
			}	
			public int Width{  //readonly 
				get{ return width;}
			}	
			
            public CImage(){
				hImage = -1;
				CheckForError(FSDK.CreateEmptyImage(ref hImage));
				height = 0;
				width = 0;
			}
			public CImage(int ImageHandle){ //constructor for making CImage from image already loaded to FaceSDK
				hImage = ImageHandle;
				PopulateHeightAndWidth();
			}
			public CImage(string FileName){
				hImage = -1;
				CheckForError(FSDK.LoadImageFromFile(ref hImage, FileName));
				PopulateHeightAndWidth();
			}
			CImage(IntPtr BitmapHandle){
				hImage = -1;
				CheckForError(FSDK.LoadImageFromHBitmap(ref hImage, BitmapHandle));
				PopulateHeightAndWidth();
			}
			CImage(System.Drawing.Image ImageObject){
				hImage = -1;
				CheckForError(FSDK.LoadImageFromCLRImage(ref hImage, ImageObject));
				PopulateHeightAndWidth();
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
                    if (hImage >= 0){
                        FSDK.FreeImage(hImage);
                        hImage = -1;
                    }
                }
                disposed = true;
            }
			~CImage(){
                Dispose(false);
			}
            
            public TFacePosition DetectFace(){
				TFacePosition fp = new FSDK.TFacePosition();
				int res = FSDK.DetectFace(hImage, ref fp);
				if (FSDKE_FACE_NOT_FOUND == res){
					fp = new FSDK.TFacePosition();
					fp.xc = 0;
					fp.yc = 0;
					fp.angle = 0;
					fp.w = 0;
				} else {
					CheckForError(res);
				}
				return fp;
			}
			public FSDK.TFacePosition[] DetectMultipleFaces(){
				FSDK.TFacePosition [] FaceArray;
				int detected = 0;
				int res = FSDK.DetectMultipleFaces(hImage, ref detected, out FaceArray, FSDK.sizeofTFacePosition*1024);
				if (FSDKE_FACE_NOT_FOUND == res)
					FaceArray = new FSDK.TFacePosition[0];
				else 
					CheckForError(res);
				return FaceArray;
			}
			public FSDK.TPoint[] DetectEyes(){
				FSDK.TPoint[] feats;
				CheckForError(FSDK.DetectEyes(hImage, out feats));
				return feats;
			}
			public FSDK.TPoint[] DetectEyesInRegion(ref FSDK.TFacePosition FacePosition){
				FSDK.TPoint[] feats;
				CheckForError(FSDK.DetectEyesInRegion(hImage, ref FacePosition, out feats));
				return feats;
			}
			public FSDK.TPoint[] DetectFacialFeatures(){
				FSDK.TPoint[] feats;
				CheckForError(FSDK.DetectFacialFeatures(hImage, out feats));
				return feats;
			}
			public FSDK.TPoint[] DetectFacialFeaturesInRegion(ref FSDK.TFacePosition FacePosition){
				FSDK.TPoint[] feats;
				CheckForError(FSDK.DetectFacialFeaturesInRegion(hImage, ref FacePosition, out feats));
				return feats;
			}
			public CImage MirrorVertical(){
				CheckForError(FSDK.MirrorImage(hImage, false));
				return this;
			}
			public CImage MirrorHorizontal(){
				CheckForError(FSDK.MirrorImage(hImage, true));
				return this;
			}
			public CImage Resize(double Ratio){
				int NewImage = -1;
				CheckForError(FSDK.CreateEmptyImage(ref NewImage));
				CheckForError(FSDK.ResizeImage(hImage, Ratio, NewImage));
				return new CImage(NewImage);
			}
			public CImage Rotate(double Angle){
				int NewImage = -1;
				CheckForError(FSDK.CreateEmptyImage(ref NewImage));
				CheckForError(FSDK.RotateImage(hImage, Angle, NewImage));
				return new CImage(NewImage);
			}
			public CImage Rotate90(int Multiplier){
				int NewImage = -1;
				CheckForError(FSDK.CreateEmptyImage(ref NewImage));
				CheckForError(FSDK.RotateImage90(hImage, Multiplier, NewImage));
				return new CImage(NewImage);
			}
			public CImage Copy(){
				int NewImage = -1;
				CheckForError(FSDK.CreateEmptyImage(ref NewImage));
				CheckForError(FSDK.CopyImage(hImage, NewImage));
				return new CImage(NewImage);
			}
			public CImage CopyRect(int x1, int y1, int x2, int y2){
				int NewImage = -1;
				CheckForError(FSDK.CreateEmptyImage(ref NewImage));
				CheckForError(FSDK.CopyRect(hImage, x1, y1, x2, y2, NewImage));
				return new CImage(NewImage);
			}
			public CImage CopyRectReplicateBorder(int x1, int y1, int x2, int y2){
				int NewImage = -1;
				CheckForError(FSDK.CreateEmptyImage(ref NewImage));
				CheckForError(FSDK.CopyRectReplicateBorder(hImage, x1, y1, x2, y2, NewImage));
				return new CImage(NewImage);
			}
			public void Save(string FileName){
				CheckForError(FSDK.SaveImageToFile(hImage, FileName));
			}
			public IntPtr GetHbitmap(){
				IntPtr bmh = IntPtr.Zero;
				CheckForError(FSDK.SaveImageToHBitmap(hImage, ref bmh));
				return bmh;
			}
			public System.Drawing.Image ToCLRImage(){
				System.Drawing.Image img = new System.Drawing.Bitmap(1,1);
				CheckForError(FSDK.SaveImageToCLRImage(hImage, ref img));
				return img;
			}
			public byte[] GetFaceTemplate(){
				byte[] tmpl;
				CheckForError(FSDK.GetFaceTemplate(hImage, out tmpl));
				return tmpl;
			}
			public byte[] GetFaceTemplateInRegion(ref FSDK.TFacePosition FacePosition){
				byte[] tmpl;
				CheckForError(FSDK.GetFaceTemplateInRegion(hImage, ref FacePosition, out tmpl));
				return tmpl;
			}
			public byte[] GetFaceTemplateUsingEyes(ref FSDK.TPoint[] EyeCoords){
				byte[] tmpl;
				CheckForError(FSDK.GetFaceTemplateUsingEyes(hImage, ref EyeCoords, out tmpl));
				return tmpl;
			}
        }
    }
}
