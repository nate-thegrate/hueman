import 'package:flutter/material.dart';
import 'package:super_hueman/structs.dart';

class ImageHues {
  final String filename;
  final List<int> colors;
  const ImageHues(this.filename, this.colors);

  (SuperColor, SuperColor) get randomColors {
    SuperColor imageColor(int i) => SuperColor.noName(colors[i]);
    int index1 = rng.nextInt(colors.length);
    int index2 = rng.nextInt(colors.length - 1);
    if (index1 == index2) index2++;
    return (imageColor(index1), imageColor(index2));
  }

  Widget get image => SizedBox(
        width: 500,
        height: 500,
        child: Image(
          image: AssetImage('assets/public_domain_photos/$filename.jpg'),
          width: 500,
        ),
      );
}

const List<ImageHues> allImages = [
  ImageHues(
    'rainbow fish',
    [0x902511, 0x031068, 0xb76812, 0x597ac9],
  ),
  ImageHues(
    'brown coral',
    [0x794e11, 0x4998b6, 0x301203],
  ),
  ImageHues(
    'coral dark bg',
    [0x97ecd0, 0x6c0901, 0xbc8949],
  ),
  ImageHues(
    'rose coral',
    [0xc41d68, 0x122e3a, 0xf3d74c, 0x329b9e],
  ),
  ImageHues(
    'pink coral',
    [0xff3d61, 0xba7150, 0x9c985c, 0xf3a675],
  ),
  ImageHues(
    'cylinder coral',
    [0x7bd28e, 0xd8918b, 0xd17b2d, 0x7aa6c1],
  ),
  ImageHues(
    'dirt beach',
    [0x32d7d7, 0xb07d3c, 0x19404d],
  ),
  ImageHues(
    'cyan fish white reef',
    [0x27b796, 0x047b93, 0xede2ac],
  ),
  ImageHues(
    'blonde reef',
    [0xa75f1a, 0x0066b1, 0x01fdff, 0x266568],
  ),
  ImageHues(
    'weird lookin reef',
    [0x0ad9b8, 0xc32732, 0x010136, 0x1a30c0],
  ),
  ImageHues(
    'orange reef',
    [0xaf240c, 0x697a3c, 0xd8af8c],
  ),
  ImageHues(
    'flamingos',
    [0xffbb90, 0xce3811, 0xd88c83, 0x728f24],
  ),
  ImageHues(
    'football',
    [0xe8474c, 0x303050, 0x9a602e, 0xbfc871],
  ),
  ImageHues(
    'tiered field',
    [0x717a10, 0x193434, 0x659eaf, 0xb99d2b],
  ),
  ImageHues(
    'billiards',
    [0x23a288, 0x001905, 0xd3b156, 0x0c5490],
  ),
  ImageHues(
    'pumpkin gummies',
    [0xfe6b01, 0xda5c54, 0x36b47c],
  ),
  ImageHues(
    'rustic boats',
    [0x3f7966, 0x9f3f20, 0x272f29, 0x79a2c5],
  ),
  ImageHues(
    'lake near white mountains',
    [0x125e5c, 0x1c3921, 0xefd161],
  ),
  ImageHues(
    'horses on snow',
    [0x674d48, 0x3f180d],
  ),
  ImageHues(
    'koala nap',
    [0x3d4b36, 0x765252, 0x27311e, 0x815e48],
  ),
  ImageHues(
    'autumn mountain',
    [0xe5ba56, 0x363a30, 0xad99a4, 0xa8e2e9],
  ),
  ImageHues(
    'palm trees',
    [0x0494ce, 0x1f3203, 0x88b9fa, 0xfaf0e2],
  ),
  ImageHues(
    'spiky rocks',
    [0x605146, 0xeba568],
  ),
  ImageHues(
    'northern lights',
    [0x0070c3, 0x00f0a2, 0x003b59],
  ),
  ImageHues(
    'dunes',
    [0xe8aa57, 0xb6d2eb],
  ),
  ImageHues(
    'buffalo face',
    [0x382926, 0xb8928d, 0x8c4f2f],
  ),
  ImageHues(
    'swimming in rough water',
    [0x0f6e73, 0x8ed0d5],
  ),
  ImageHues(
    'horse in dry field',
    [0x82533e, 0xa2917c, 0x615b48],
  ),
  ImageHues(
    'pink mountains',
    [0xffbfd4, 0x9ca7c8, 0xf07391],
  ),
  ImageHues(
    'jade leaves',
    [0x77a18d, 0x02211f],
  ),
  ImageHues(
    'autumn pine forest',
    [0x323a20, 0xd89929, 0x575139],
  ),
  ImageHues(
    'dock lake mountains',
    [0xedd1b8, 0x1f2d4a],
  ),
  ImageHues(
    'orange cloud',
    [0x6a3a3f, 0x4c4557, 0xfb7320],
  ),
  ImageHues(
    'deer orange forest',
    [0x401617, 0x6a1c04, 0xf8cd73],
  ),
  ImageHues(
    'archipeligo',
    [0x050b48, 0xa5daef, 0x284c25],
  ),
  ImageHues(
    'boat and feet',
    [0x304659, 0x2b3727, 0xb37d5f, 0x5d716e],
  ),
  ImageHues(
    'balloon on lake',
    [0x00342e, 0xb4d3f3, 0xffdf50, 0x0d2314],
  ),
  ImageHues(
    'leaves',
    [0x4c8066, 0xb19089, 0x032728],
  ),
  ImageHues(
    'leaf',
    [0x367219, 0x608956],
  ),
  ImageHues(
    'ocean',
    [0x011924, 0xb5e3ec],
  ),
  ImageHues(
    'cloudy beach',
    [0x5d847b, 0xdcd0c1, 0x495131],
  ),
  ImageHues(
    'sunset palm trees',
    [0xfe947b, 0xb67682, 0x434152],
  ),
  ImageHues(
    'canyon',
    [0xfff6bb, 0xb94c1c, 0x835854],
  ),
  ImageHues(
    'rocks',
    [0x3c6368, 0xc1a797, 0x112538],
  ),
  ImageHues(
    'roses dark leaves',
    [0x70162e, 0xa8acc6, 0x233e3d],
  ),
  ImageHues(
    'earth nighttime',
    [0x00001a, 0x0f1f50, 0xf0d486],
  ),
  ImageHues(
    'yellow frog',
    [0xfff282, 0x1c112a, 0x7687b8, 0x689b57],
  ),
  ImageHues(
    'blue frog',
    [0x6e87c9, 0x554c7a, 0x656514],
  ),
  ImageHues(
    'peacock feathers',
    [0x0b0a50, 0x6f6565, 0x3c6757],
  ),
  ImageHues(
    'purple sky',
    [0x905e75, 0x221a2e],
  ),
  ImageHues(
    'dock evening',
    [0x06132a, 0x6f5170, 0x442e3a],
  ),
  ImageHues(
    'amber waves of grain',
    [0xaeccee, 0xf3e8ae],
  ),
  ImageHues(
    'birb',
    [0xbf6c18, 0x999c88],
  ),
  ImageHues(
    'forest mountain lake ripples',
    [0xd28451, 0x2b3d3e],
  ),
  ImageHues(
    'mountain lake dark clouds',
    [0x372929, 0x2a5f56, 0xc78b27, 0xf9d5b4],
  ),
  ImageHues(
    'autumn forest',
    [0x31494e, 0xc0883f],
  ),
  ImageHues(
    'dense forest',
    [0x1b2024, 0x272c22],
  ),
  ImageHues(
    'leaves and foggy lake',
    [0x8da4a3, 0x38433e, 0x746d3d],
  ),
  ImageHues(
    'brown river',
    [0x67423e, 0xb4ba2e, 0x1d2925],
  ),
  ImageHues(
    'tiger',
    [0x864a21, 0x333b39, 0x618189],
  ),
  ImageHues(
    'green snek',
    [0x7adbba, 0xd1f411, 0x906b3d],
  ),
  ImageHues(
    'lotus I think',
    [0xf73d54, 0x638101],
  ),
  ImageHues(
    'mountain lake yellow flowers',
    [0x018165, 0x87a046, 0xfdd903],
  ),
  ImageHues(
    'tall trees',
    [0xcd793d, 0x26320a, 0xb3fffe],
  ),
  ImageHues(
    'forest road',
    [0x627a28, 0xccbc9d, 0xe1d5c0],
  ),
  ImageHues(
    'yellow tulips',
    [0xfee59c, 0x0183b3, 0x274c3a],
  ),
  ImageHues(
    'gray dock sunset',
    [0x725dc2, 0xfeaf8f, 0xd4b1de],
  ),
  ImageHues(
    'red berries',
    [0xee211e, 0x394532, 0x426650],
  ),
  ImageHues(
    'lettuce',
    [0xd4d58c, 0x55692a, 0x32453a],
  ),
  ImageHues(
    'red flowers white bg',
    [0x7a0103, 0xc39e59, 0x746a02],
  ),
  ImageHues(
    'bees',
    [0xe197f6, 0xe4ba4e],
  ),
  ImageHues(
    'old car interior',
    [0xab602a, 0x455739, 0x79d0d8],
  ),
  ImageHues(
    'city sunset silhouette',
    [0x9d1c26, 0xffd684],
  ),
  ImageHues(
    'golden gate bridge',
    [0xeb674f, 0xb0d9fc, 0x1d244f],
  ),
  ImageHues(
    'elephants',
    [0x9e734d, 0xe8bb5c, 0xb1d0fb],
  ),
  ImageHues(
    'cool building',
    [0xaf6f47, 0x475859],
  ),
  ImageHues(
    'statue of liberty',
    [0x92dbcc, 0x67a6ff],
  ),
  ImageHues(
    'american flag',
    [0x263562, 0xb71c35],
  ),
  ImageHues(
    'icy cyan lake',
    [0x88a5bb, 0x15a8aa],
  ),
  ImageHues(
    'hummingbird',
    [0xf34da3, 0x1042a7, 0x00766c],
  ),
  ImageHues(
    'path through foggy forest',
    [0x845e49, 0x879661],
  ),
  ImageHues(
    'jade violet northern lights',
    [0x6db893, 0x512d4e],
  ),
  ImageHues(
    'path up a mountain',
    [0xba6889, 0x356d41],
  ),
  ImageHues(
    'forest road closeup',
    [0xfda751, 0x4f8230, 0x465a53],
  ),
  ImageHues(
    'lion',
    [0x5b2f16, 0xadba95, 0xd0c2b8],
  ),
  ImageHues(
    'forest bridge',
    [0xcfb7aa, 0x43521d],
  ),
  ImageHues(
    'zoomed-in grass or something',
    [0xc0b766, 0x8dab96],
  ),
  ImageHues(
    'lots of stars',
    [0x1b5690, 0xdccbbb, 0x1c2442],
  ),
  ImageHues(
    'brown-striped jellyfish',
    [0x391403, 0x020623],
  ),
  ImageHues(
    'pink-ish flowers',
    [0xf2bcab, 0x2b6a31],
  ),
  ImageHues(
    'beach from above',
    [0x01b1ac, 0xf6d4ce],
  ),
  ImageHues(
    'river painting',
    [0xe94c31, 0x223028, 0x4b7e95, 0xd2c59e],
  ),
  ImageHues(
    'planet earth',
    [0x050d37, 0xca8f71],
  ),
  ImageHues(
    'bird drawing',
    [0x48693d, 0xbd382b, 0xe4ae82],
  ),
  ImageHues(
    'fish painting',
    [0x15715a, 0xff855e, 0x313b46],
  ),
  ImageHues(
    'picasso I think',
    [0x632e10, 0x343325, 0xe8c398],
  ),
  ImageHues(
    'asian painting',
    [0x9cb9c5, 0x0d1043, 0xe6d1ae, 0x8b865b],
  ),
  ImageHues(
    'chameleon',
    [0x028609, 0x7b5b8b, 0x848410],
  ),
  ImageHues(
    'red-eyed tree frog',
    [0xff5d22, 0x386600, 0x0079f4],
  ),
  ImageHues(
    'we can do it',
    [0x193977, 0xf2d359, 0xfc6f2f, 0xdfb089],
  ),
  ImageHues(
    'washington',
    [0xac7152, 0x362a10, 0xffe3a3],
  ),
  ImageHues(
    'pennies',
    [0xba6b2a, 0x8e591d, 0x304029],
  ),
  ImageHues(
    'orange',
    [0xb78049, 0x96612b, 0xb57c43],
  ),
  ImageHues(
    'santa',
    [0xad1615, 0x193f3c, 0xeaa490],
  ),
  ImageHues(
    'obama',
    [0xe9ac86, 0x20407d, 0xba5b4e, 0x404e66],
  ),
  ImageHues(
    'a famous painting',
    [0x78200a, 0xf7ef98, 0x6e401f, 0x168f53],
  ),
  ImageHues(
    'frankenstein cover I think',
    [0x3f535b, 0xc0cfe5, 0xb9996e],
  ),
  ImageHues(
    'starry night',
    [0xe6cd21, 0x5992d3, 0x291b10, 0x0b0d22],
  ),
  ImageHues(
    'mona lisa',
    [0xeebb71, 0x723310, 0x48697f],
  ),
  ImageHues(
    'rose',
    [0xef3390, 0xb43d04, 0x263f1b],
  ),
  ImageHues(
    'red roofs',
    [0xd67350, 0x5c94cf, 0xb5e4e4],
  ),
  ImageHues(
    'pride flag',
    [0x1465d4, 0x6b2b8a, 0xaec24f, 0xe9cae1],
  ),
];
