import 'package:flutter/material.dart';
import 'package:hueman/data/super_color.dart';

class Photo extends StatelessWidget {
  const Photo(this.filename, this.colors, {super.key});
  final String filename;
  final List<int> colors;

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/public_domain_photos/$filename.jpg');
  }
}

extension type RandomColors(List<SuperColor> colors) implements List<SuperColor> {
  RandomColors.fromShuffledList(List<int> list)
      : this([SuperColor(list[0]), SuperColor(list[1])]);
  RandomColors.fromIntList(List<int> list) : this.fromShuffledList(list.toList()..shuffle());
}

extension type PhotoColors(List<(Photo, RandomColors)> photoColors) {
  PhotoColors.fromPhotoList(List<Photo> photos)
      : this([for (final photo in photos) (photo, RandomColors.fromIntList(photo.colors))]);

  (Photo, SuperColor) pop() {
    final (photo, colors) = photoColors.first;
    final color = colors.removeAt(0);
    if (colors.isEmpty) photoColors.removeAt(0);
    return (photo, color);
  }

  bool get isEmpty => photoColors.isEmpty;
}

const List<Photo> allImages = [
  Photo(
    'rose coral',
    [0xc41d68, 0x122e3a, 0xf3d74c, 0x329b9e],
  ),
  Photo(
    'pink coral',
    [0xff3d61, 0xba7150, 0x9c985c, 0xf3a675],
  ),
  Photo(
    'dirt beach',
    [0x32d7d7, 0xb07d3c, 0x19404d],
  ),
  Photo(
    'blonde reef',
    [0xa75f1a, 0x0066b1, 0x01fdff, 0x266568],
  ),
  Photo(
    'orange reef',
    [0xaf240c, 0x697a3c, 0xd8af8c],
  ),
  Photo(
    'flamingos',
    [0xffbb90, 0xce3811, 0xd88c83, 0x728f24],
  ),
  Photo(
    'football',
    [0xe8474c, 0x303050, 0x9a602e, 0xbfc871],
  ),
  Photo(
    'tiered field',
    [0x717a10, 0x193434, 0x659eaf, 0xb99d2b],
  ),
  Photo(
    'billiards',
    [0x23a288, 0x001905, 0xd3b156, 0x0c5490],
  ),
  Photo(
    'pumpkin gummies',
    [0xfe6b01, 0xda5c54, 0x36b47c],
  ),
  Photo(
    'rustic boats',
    [0x3f7966, 0x9f3f20, 0x272f29, 0x79a2c5],
  ),
  Photo(
    'lake near white mountains',
    [0x125e5c, 0x1c3921, 0xefd161],
  ),
  Photo(
    'koala nap',
    [0x3d4b36, 0x765252, 0x27311e, 0x815e48],
  ),
  Photo(
    'autumn mountain',
    [0xe5ba56, 0x363a30, 0xad99a4, 0xa8e2e9],
  ),
  Photo(
    'northern lights',
    [0x0070c3, 0x00f0a2, 0x003b59],
  ),
  Photo(
    'dunes',
    [0xe8aa57, 0xb6d2eb],
  ),
  Photo(
    'buffalo face',
    [0x382926, 0xb8928d, 0x8c4f2f],
  ),
  Photo(
    'swimming in rough water',
    [0x0f6e73, 0x8ed0d5],
  ),
  Photo(
    'horse in dry field',
    [0x82533e, 0xa2917c, 0x615b48],
  ),
  Photo(
    'pink mountains',
    [0xffbfd4, 0x9ca7c8, 0xf07391],
  ),
  Photo(
    'spring leaves',
    [0x77a18d, 0x02211f],
  ),
  Photo(
    'autumn pine forest',
    [0x323a20, 0xd89929, 0x575139],
  ),
  Photo(
    'dock lake mountains',
    [0xedd1b8, 0x1f2d4a],
  ),
  Photo(
    'orange cloud',
    [0x6a3a3f, 0x4c4557, 0xfb7320],
  ),
  Photo(
    'deer orange forest',
    [0x401617, 0x6a1c04, 0xf8cd73],
  ),
  Photo(
    'archipeligo',
    [0x050b48, 0xa5daef, 0x284c25],
  ),
  Photo(
    'boat and feet',
    [0x304659, 0x2b3727, 0xb37d5f, 0x5d716e],
  ),
  Photo(
    'balloon on lake',
    [0x00342e, 0xb4d3f3, 0xffdf50, 0x0d2314],
  ),
  Photo(
    'leaves',
    [0x4c8066, 0xb19089, 0x032728],
  ),
  Photo(
    'ocean',
    [0x011924, 0xb5e3ec],
  ),
  Photo(
    'cloudy beach',
    [0x5d847b, 0xdcd0c1, 0x495131],
  ),
  Photo(
    'sunset palm trees',
    [0xfe947b, 0xb67682, 0x434152],
  ),
  Photo(
    'canyon',
    [0xfff6bb, 0xb94c1c, 0x835854],
  ),
  Photo(
    'rocks',
    [0x3c6368, 0xc1a797, 0x112538],
  ),
  Photo(
    'roses dark leaves',
    [0x70162e, 0xa8acc6, 0x233e3d],
  ),
  Photo(
    'yellow frog',
    [0xfff282, 0x1c112a, 0x7687b8, 0x689b57],
  ),
  Photo(
    'peacock feathers',
    [0x0b0a50, 0x6f6565, 0x3c6757],
  ),
  Photo(
    'purple sky',
    [0x905e75, 0x221a2e],
  ),
  Photo(
    'dock evening',
    [0x06132a, 0x6f5170, 0x442e3a],
  ),
  Photo(
    'amber waves of grain',
    [0xaeccee, 0xf3e8ae],
  ),
  Photo(
    'birb',
    [0xbf6c18, 0x999c88],
  ),
  Photo(
    'forest mountain lake ripples',
    [0xd28451, 0x2b3d3e],
  ),
  Photo(
    'mountain lake dark clouds',
    [0x372929, 0x2a5f56, 0xc78b27, 0xf9d5b4],
  ),
  Photo(
    'dense forest',
    [0x1b2024, 0x272c22],
  ),
  Photo(
    'leaves and foggy lake',
    [0x8da4a3, 0x38433e, 0x746d3d],
  ),
  Photo(
    'brown river',
    [0x67423e, 0xb4ba2e, 0x1d2925],
  ),
  Photo(
    'tiger',
    [0x864a21, 0x333b39, 0x618189],
  ),
  Photo(
    'green snek',
    [0x7adbba, 0xd1f411, 0x906b3d],
  ),
  Photo(
    'lotus I think',
    [0xf73d54, 0x638101],
  ),
  Photo(
    'forest road',
    [0x627a28, 0xccbc9d, 0xe1d5c0],
  ),
  Photo(
    'yellow tulips',
    [0xfee59c, 0x0183b3, 0x274c3a],
  ),
  Photo(
    'gray dock sunset',
    [0x725dc2, 0xfeaf8f, 0xd4b1de],
  ),
  Photo(
    'gold rings',
    [0x705827, 0xefc16a, 0xbe7409],
  ),
  Photo(
    'red berries',
    [0xee211e, 0x394532, 0x426650],
  ),
  Photo(
    'lettuce',
    [0xd4d58c, 0x55692a, 0x32453a],
  ),
  Photo(
    'red flowers white bg',
    [0x7a0103, 0xc39e59, 0x746a02],
  ),
  Photo(
    'bees',
    [0xe197f6, 0xe4ba4e],
  ),
  Photo(
    'old car interior',
    [0xab602a, 0x455739, 0x79d0d8],
  ),
  Photo(
    'city sunset silhouette',
    [0x9d1c26, 0xffd684],
  ),
  Photo(
    'golden gate bridge',
    [0xeb674f, 0xb0d9fc, 0x1d244f],
  ),
  Photo(
    'elephants',
    [0x9e734d, 0xe8bb5c, 0xb1d0fb],
  ),
  Photo(
    'cool building',
    [0xaf6f47, 0x475859],
  ),
  Photo(
    'statue of liberty',
    [0x92dbcc, 0x67a6ff],
  ),
  Photo(
    'american flag',
    [0x263562, 0xb71c35],
  ),
  Photo(
    'icy cyan lake',
    [0x88a5bb, 0x15a8aa],
  ),
  Photo(
    'hummingbird',
    [0xf34da3, 0x1042a7, 0x00766c],
  ),
  Photo(
    'path through foggy forest',
    [0x845e49, 0x879661],
  ),
  Photo(
    'spring violet northern lights',
    [0x6db893, 0x512d4e],
  ),
  Photo(
    'path up a mountain',
    [0xba6889, 0x356d41],
  ),
  Photo(
    'forest road closeup',
    [0xfda751, 0x4f8230, 0x465a53],
  ),
  Photo(
    'lion',
    [0x5b2f16, 0xadba95, 0xd0c2b8],
  ),
  Photo(
    'forest bridge',
    [0xcfb7aa, 0x43521d],
  ),
  Photo(
    'zoomed-in grass or something',
    [0xc0b766, 0x8dab96],
  ),
  Photo(
    'lots of stars',
    [0x1b5690, 0xdccbbb, 0x1c2442],
  ),
  Photo(
    'brown-striped jellyfish',
    [0x391403, 0x020623],
  ),
  Photo(
    'pink-ish flowers',
    [0xf2bcab, 0x2b6a31],
  ),
  Photo(
    'beach from above',
    [0x01b1ac, 0xf6d4ce],
  ),
  Photo(
    'river painting',
    [0xe94c31, 0x223028, 0x4b7e95, 0xd2c59e],
  ),
  Photo(
    'planet earth',
    [0x050d37, 0xca8f71],
  ),
  Photo(
    'fish painting',
    [0x15715a, 0xff855e, 0x313b46],
  ),
  Photo(
    'picasso I think',
    [0x632e10, 0x343325, 0xe8c398],
  ),
  Photo(
    'asian painting',
    [0x9cb9c5, 0x0d1043, 0xe6d1ae, 0x8b865b],
  ),
  Photo(
    'chameleon',
    [0x028609, 0x7b5b8b, 0x848410],
  ),
  Photo(
    'red-eyed tree frog',
    [0xff5d22, 0x386600, 0x0079f4],
  ),
  Photo(
    'we can do it',
    [0x193977, 0xf2d359, 0xfc6f2f, 0xdfb089],
  ),
  Photo(
    'washington',
    [0xac7152, 0x362a10, 0xffe3a3],
  ),
  Photo(
    'pennies',
    [0xba6b2a, 0x8e591d, 0x304029],
  ),
  Photo(
    'orange',
    [0xb78049, 0x96612b, 0xb57c43],
  ),
  Photo(
    'santa',
    [0xad1615, 0x193f3c, 0xeaa490],
  ),
  Photo(
    'a famous painting',
    [0x78200a, 0xf7ef98, 0x6e401f, 0x168f53],
  ),
  Photo(
    'frankenstein cover I think',
    [0x3f535b, 0xc0cfe5, 0xb9996e],
  ),
  Photo(
    'starry night',
    [0xe6cd21, 0x5992d3, 0x291b10, 0x0b0d22],
  ),
  Photo(
    'mona lisa',
    [0xeebb71, 0x723310, 0x48697f],
  ),
  Photo(
    'rose',
    [0xef3390, 0xb43d04, 0x263f1b],
  ),
  Photo(
    'red roofs',
    [0xd67350, 0x5c94cf, 0xb5e4e4],
  ),
  Photo(
    'pride flag',
    [0x1465d4, 0x6b2b8a, 0xaec24f, 0xe9cae1],
  ),
];
