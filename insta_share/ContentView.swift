//
//  ContentView.swift
//  insta_share
//
//  Created by 三浦将太 on 2021/05/12.
//

import SwiftUI

struct ContentView: View {
    
    @State var buttonText = "スタンプ＆背景色"
    @State var buttonText2 = "背景＆スタンプ画像"
    @State var randomText = "Hello"
    //PDF保存用　兼UIImage出力用
    @State private var rect: CGRect = .zero
    @State var uiImage: UIImage? = nil
    @State private var showActivityView: Bool = false
    //画像保存用
    @State var showAlert = false
    
    var body: some View {
        var url = fileSave(fileName: "PDF名前.pdf")
        NavigationView{
            VStack {
                Text("Hello, world!")
                    .padding()
                
                //スタンプ＆背景色
                Button(action: {
                    
                    self.uiImage = UIApplication.shared.windows[0].rootViewController?.view!.getImage(rect: self.rect)
                    
                    let radiusImage = uiImage?.withRoundedCorners(radius: 20)
                    
                    if let image = radiusImage {
                        shareStickerImage(uiImage: image)
                    }
                    
                    //action
                    buttonText = "Button Tapped"
                }) {
                    //タップされるボタン
                    Text(buttonText)
                                   .font(.largeTitle)
                }
                
                //背景＆スタンプ画像
                Button(action: {
                    
                    self.uiImage = UIApplication.shared.windows[0].rootViewController?.view!.getImage(rect: self.rect)
                    
                    let radiusImage = uiImage?.withRoundedCorners(radius: 20)
                    
                    if let image = radiusImage {
                        shareBackgroundAndStickerImage(uiImage: image)
                    }
                    
                    //action
                    buttonText2 = "Button Tapped"
                }) {
                    //タップされるボタン
                    Text(buttonText2)
                                   .font(.largeTitle)
                }
                
                //画像保存用
                Button(action: {
                    
                    self.uiImage = UIApplication.shared.windows[0].rootViewController?.view!.getImage(rect: self.rect)
                    
                    let radiusImage = uiImage?.withRoundedCorners(radius: 20)
                    
                    if let image = radiusImage {
                        ImageSaver($showAlert).writeToPhotoAlbum(image: image)
                    }
                    
                    
                  }){
                    Text("PNG出力")
                                        .padding()
                                        .foregroundColor(Color.white)
                                        .background(Color.red)
                                        .cornerRadius(8)
                  }.alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("画像を保存しました。"),
                        message: Text(""),
                        dismissButton: .default(Text("OK"), action: {
                            showAlert = false
                        }))
                  }
                
                //PDF出力ボタン
                Button(action: {
                    //action
                    self.showActivityView.toggle()
                    self.uiImage = UIApplication.shared.windows[0].rootViewController?.view!.getImage(rect: self.rect)
                    
                    let radiusImage = uiImage?.withRoundedCorners(radius: 20)
                    
                    createPdfFromView(hosting: UIImageView(image: radiusImage), saveToDocumentsWithFileName: "PDF名前")
                                
                }) {
                    //タップされるボタン
                    Text("PDF出力")
                                        .padding()
                                        .foregroundColor(Color.white)
                                        .background(Color.red)
                                        .cornerRadius(8)
                }.sheet(isPresented: self.$showActivityView) {
                    ActivityView(
                        activityItems: [url],

                        applicationActivities: nil
                    )
                }
                
                Label {
                    Text("\(randomText)"+"\n"+"\(randomText)")
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .background(RectangleGetter(rect: $rect))
                } icon: {
                    }
                
                  }
        }.onAppear{
            let random = randomString(length: 10)// 10桁のランダムな英数字を生成
            randomText = random
            
            //CGRectで取得した範囲をUIImageに変換
            self.uiImage = UIApplication.shared.windows[0].rootViewController?.view!.getImage(rect: self.rect)
            
            //PDFを一時保存
            createPdfFromView(hosting:UIImageView(image:uiImage),saveToDocumentsWithFileName:"PDF名前")
        }.onDisappear {
            print("DetailViewを非表示")
        }
    }
}

//取得する画像と同サイズのレイヤーを作る
struct RectangleGetter: View {
    @Binding var rect: CGRect
    
    let radius: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            self.createView(proxy: geometry)
            
//            Path { path in
//                let frame = geometry.frame(in: .local)
//
//                path.move(to: CGPoint(x: frame.minX, y: frame.midY))
//                // 各角に弧を描いていき、角丸にする
//                path.addArc(tangent1End: CGPoint(x: frame.minX, y: frame.minY),
//                            tangent2End: CGPoint(x: frame.midX, y: frame.minY),
//                            radius: self.radius)
//                path.addArc(tangent1End: CGPoint(x: frame.maxX, y: frame.minY),
//                            tangent2End: CGPoint(x: frame.maxX, y: frame.midY),
//                            radius: self.radius)
//                path.addArc(tangent1End: CGPoint(x: frame.maxX, y: frame.maxY),
//                            tangent2End: CGPoint(x: frame.midX, y: frame.maxY),
//                            radius: self.radius)
//                path.addArc(tangent1End: CGPoint(x: frame.minX, y: frame.maxY),
//                            tangent2End: CGPoint(x: frame.minX, y: frame.midY),
//                            radius: self.radius)
//            }
        }
    }

    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = proxy.frame(in: .global)
        }
        return RoundedRectangle(cornerRadius: 20).fill(Color.clear)
        //return Rectangle().fill(Color.clear)
    }
}

//SwiftUIのViewをUIimageに変換
//extension UIView {
//    func getImage(rect: CGRect) -> UIImage {
//        let renderer = UIGraphicsImageRenderer(bounds: rect)
//        return renderer.image { rendererContext in
//            layer.render(in: rendererContext.cgContext)
//        }
//    }
//}

extension UIView {
    func getImage(rect: CGRect) -> UIImage {
//        let ctx: CGContext = UIGraphicsGetCurrentContext()!
//        let clipPath: CGPath = UIBezierPath(roundedRect: rect, cornerRadius: 50).cgPath
//        ctx.addPath(clipPath)
//        ctx.closePath()
//        ctx.fillPath()
        
        let renderer = UIGraphicsImageRenderer(bounds: rect)

        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

//UIImageをPDFとして一時保存
func createPdfFromView(hosting: UIImageView, saveToDocumentsWithFileName fileName: String) {
    let pdfData = NSMutableData()
    UIGraphicsBeginPDFContextToData(pdfData, hosting.bounds, nil)
    UIGraphicsBeginPDFPage()
    guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
    hosting.layer.render(in: pdfContext)
    UIGraphicsEndPDFContext()
    if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
        let documentsFileName = documentDirectories + "/" + fileName + ".pdf"
        pdfData.write(toFile: documentsFileName, atomically: true)
    }
}

//PDFが一時保存されているディレクトリからフルパスを取得
func fileSave(fileName: String) -> URL {
    let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first!
    let filePath = dir.appendingPathComponent(fileName, isDirectory: false);
    return filePath
}

//PDF出力ボタンを押した際に画面下部から表示されるアクティブシート
struct ActivityView: UIViewControllerRepresentable {

    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ActivityView>
    ) -> UIActivityViewController {
        return UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityView>
    ) {
        // Nothing to do
    }
}

//スタンプと背景色を指定
func shareStickerImage(uiImage:UIImage) {
    let url = URL(string: "instagram-stories://share")
    //スタンプ画像を設定
    //let pngImageData = UIImage(named: "fish.jpeg")?.pngData()
    let pngImageData = uiImage.pngData()
    
//    let imageView = UIImageView(image:uiImage)
//    imageView.layer.cornerRadius = 30
//            imageView.clipsToBounds = true
//    let ImageData = imageView.image
//    let pngImageData = ImageData?.pngData()
    
    let items: NSArray = [["com.instagram.sharedSticker.stickerImage": pngImageData!,
                           "com.instagram.sharedSticker.backgroundTopColor": "#00ff00",
                           "com.instagram.sharedSticker.backgroundBottomColor": "#ff00ff"]]
    UIPasteboard.general.setItems(items as! [[String : Any]], options: [:])
    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
}

//背景・スタンプ画像と背景色を指定
func shareBackgroundAndStickerImage(uiImage:UIImage) {
        let url = URL(string: "instagram-stories://share")
        //背景画像を設定
        //let pngImageData = UIImage(named: "fish.jpeg")?.pngData()
        let pngImageData = uiImage.pngData()
        //スタンプ画像を設定
        //let pngStickerData = UIImage(named: "fish.jpeg")?.pngData()
        let pngStickerData = uiImage.pngData()
        let items: NSArray = [["com.instagram.sharedSticker.backgroundImage": pngImageData!,
                               "com.instagram.sharedSticker.stickerImage": pngStickerData!,
                               //背景色と背景画像の両方を設定すると背景画像が優先されて表示される為、以下は不要
                               "com.instagram.sharedSticker.backgroundTopColor": "#00ff00",
                               "com.instagram.sharedSticker.backgroundBottomColor": "#ff00ff"]]
        UIPasteboard.general.setItems(items as! [[String : Any]], options: [:])
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
}

//ランダムな文字列を生成
func randomString(length: Int) -> String {

    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)

    var randomString = ""

    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }

    return randomString
}

//画像保存用
class ImageSaver: NSObject {
    @Binding var showAlert: Bool
    
    init(_ showAlert: Binding<Bool>) {
        _showAlert = showAlert
    }
    
    func writeToPhotoAlbum(image: UIImage) {
        let png = image.pngData()!
        let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
        try? png.write(to: filename)
        if UIImage(contentsOfFile: filename.path) != nil{
            UIImageWriteToSavedPhotosAlbum((UIImage(named: filename.path) ?? UIImage(named: "hoge.png"))!, self, #selector(didFinishSavingImage), nil)
            print(filename.path)
        }
//        let pngImage = UIImage.init(data: png)!
//        UIImageWriteToSavedPhotosAlbum(pngImage, self, #selector(didFinishSavingImage), nil)
    }

    @objc func didFinishSavingImage(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if error != nil {
            print("保存に失敗しました。")
        } else {
            showAlert = true
        }
    }
}

//ドキュメントURL取得
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

//UIImageを角丸に変換
extension UIImage {
        // image with rounded corners
        public func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
            let maxRadius = min(size.width, size.height) / 2
            let cornerRadius: CGFloat
            if let radius = radius, radius > 0 && radius <= maxRadius {
                cornerRadius = radius
            } else {
                cornerRadius = maxRadius
            }
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            let rect = CGRect(origin: .zero, size: size)
            UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
            draw(in: rect)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
