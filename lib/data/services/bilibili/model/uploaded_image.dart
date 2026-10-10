class UploadedImage {
  final String src;
  final int width;
  final int height;
  final double size;
  // 这个字段恒定为0, 虽然b站准备了这个字段, 但上传接口并不具备检测aigc的能力
  final int aiGenPic = 0;

  UploadedImage({
    required this.src,
    required this.width,
    required this.height,
    required this.size,
  });

  factory UploadedImage.fromJson(Map<String, dynamic> json) {
    return UploadedImage(
      src: json['image_url'],
      width: json['image_width'] as int,
      height: json['image_height'] as int,
      size: json['img_size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'img_src': src,
      'img_width': width,
      'img_height': height,
      'img_size': size,
      'ai_gen_pic': aiGenPic,
    };
  }
}
