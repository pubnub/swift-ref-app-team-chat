//
//  Ext+PubNub.swift
//
//  PubNub Real-time Cloud-Hosted Push API and Push Notification Client Frameworks
//  Copyright © 2020 PubNub Inc.
//  https://www.pubnub.com/
//  https://www.pubnub.com/terms
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS": WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

import PubNub
import PubNubCSM

// MARK: User Detail View
extension Timetoken {
  var inSeconds: Timetoken {
    return self/10000000
  }
}

extension Date {
  /// 15-digit precision unix time (UTC) since 1970
  ///
  /// - note: A 64-bit `Double` has a max precision of 15-digits, so
  ///         any value derived from a `TimeInterval` will not be precise
  ///         enough to rely on when querying system APIs which use
  ///         17-digit precision UTC values
  var timeIntervalAsImpreciseToken: Timetoken {
    return Timetoken(self.timeIntervalSince1970 * 10000000)
  }
}

extension User {
  static var knownUsers: [String: String] = {
    return [
      "user_a652eb6cc34b44c4a39b28fcc24d062b": "Sina Sites",
      "user_d06c7d5ddc1c4c85bd66844198b2ca38": "Ilene Iniguez",
      "user_a673547880824a0687b3041af36a5de4": "Brook Bilodeau",
      "user_102a15c8bc394bdc90d1c8eab58b1de9": "Laverne Ludden",
      "user_2ada61d287aa42b59d620c474493474f": "Cira Cray",
      "user_4ec689d24845466e93ee358c40358473": "Fredric Fraser",
      "user_83647bfb6bcd412d93b1e57e1b602d3a": "Dominick Daughtrey",
      "user_def709b1adfc4e67b98bb7a820f581b1": "Alexander Angus",
      "user_6ef19fcc68824f9f9e3d908d796f21a3": "Osvaldo Oh",
      "user_05f4ac447efc478c834e53ba0cb34444": "Quintin Quigg",
      "user_a56c20222c484ff8987ec9b69b0c8f5b": "Andree Allums",
      "user_ee7e4c6cedbf40cdaaed6de7696b9329": "Trevor Triche",
      "user_c1ee1eda28554d0f88560a51862980b3": "Gregory Goolsby",
      "user_17b13f16a5164ca4b1e4d88ea434f5a1": "Shara Stellhorn",
      "user_85d35cf84bf5456f8040cc733d9b09c9": "Martina Mcneil",
      "user_fbc9a54790b24ee19441260970b171c0": "Adelia Auten",
      "user_0368d27f4d514079bc5cfd5678ec1fe7": "Dino Darnall",
      "user_5181e07992f44e94a1a81ae9a5d25777": "Roxann Rothe",
      "user_fd6f86b6942d4940a895f4059cb188d7": "Artie Amado",
      "user_5500315bf0a34f9b9dfa0e4fffcf49c2": "Delores Dahlman",
      "user_30b5b567829e485ab6267c3c78d48ca3": "Stewart Swarts",
      "user_4caced7ebd904676a897628662f37d32": "Malcom Mehl",
      "user_0202a46151cc43af890caa521c40576e": "Sharla Stano",
      "user_b17878cd35154a258b86b63050963c74": "Mimi Margolin",
      "user_61c5af696dde4a9388f95d402767db16": "Tyrell Tubb",
      "user_0a0579891c7148009ec254f7ae2e6367": "Conchita Colone",
      "user_ed145d8b0f094b83a2d51d428a59d0cb": "Azalee Arviso",
      "user_72a0cc784d4543f2b1d9cee9961d7e49": "Hilary Herrman",
      "user_149e60f3117d4fb280c992762d3c09e3": "Loyce Letellier",
      "user_35dd06f9b2c749cfb22ddb7b938c5c7c": "Sherell Studley",
      "user_00c56e75c0334ff0b248ca4292d20de3": "Josef Jorgensen",
      "user_d43bfea6e4234f84ab377d664edf2576": "Davida Dudash",
      "user_cf808eb761754c399922e96b02ac8b94": "Keven Klaus",
      "user_31be78e92e4e4218808007047cbdcebb": "Tajuana Topete",
      "user_797c9f53bbc541f6b046fa32339bb2dd": "Virginia Vanwart",
      "user_9a197f447f314f9ead993f12303d8c75": "Marita Millis",
      "user_03bcea398fd6441c8f982abbdc94ef75": "Melba Moreman",
      "user_98dac32649e7488ea314a96f808e002d": "Jolyn Janes",
      "user_cb3460da976442579c8f4785ec687ddf": "Grady Gitlin",
      "user_29bea6fb93384c0f80254a5a9af66fe6": "Herbert Herrick",
      "user_f5735bcc168445c38978e46969bc0019": "Consuela Cozart",
      "user_363d9255193e45f19513f4bfa9901fbe": "Frank Farone",
      "user_1bc564bcaa4a476e8392c4c8e2b92983": "Doreen Dimas",
      "user_2b0a9e355fc64fa2abf5ef92c87a76cb": "Yasmin Yohe",
      "user_0b253029175b4ebb8b03c4281757406b": "Ty Tenny",
      "user_608169810dc143998c7964485415a5c7": "Eleonore Elbert",
      "user_732277cad5264ed48172c40f0f008104": "Bettina Blumer",
      "user_4190b08bba444ec58beda6637361cfdb": "Evelina Edlund",
      "user_18ded324eb4e465984b2971e990ef8c9": "Katrina Kilbane",
      "user_78c3e3420b59441380eca3928a8a5b70": "Rolande Raimondi",
      "user_3c4400761cba4b65b77b6cae55fc21eb": "Alesha Amoroso",
      "user_515fc9a2a1b043c3847a29f29f3b3c2a": "Hannah Holen",
      "user_7261c27b34954ece93ac0d8a15520591": "Brenton Bossert",
      "user_55368a92e24e4e26a2e143db53205fd3": "Patricia Payne",
      "user_f32ea4a710104c06ad5858b0e22cfc88": "Carmelita Carmouche",
      "user_2fae5cc33cfb4cc1befdc261d8c81969": "Kanisha Kyle",
      "user_d84e6dadbdab4b75bfc51e17a9089546": "Patrick Piggott",
      "user_7ec3a868038049f2a7c6515fa64814c6": "Imogene Iverson",
      "user_2bf0a23078ca4ea09ed6a86c9efa3b14": "Zula Zufelt",
      "user_efc5b3ef96ea4bffbde733e249c8cbb3": "Chantal Casares",
      "user_5be59efdf1bd49e18415c7829666c480": "Ruby Raybon",
      "user_55f74958eb00441f8171f4f8757b0f24": "Lakenya Logan",
      "user_91bfab48a8464589ae2aafb3858a9e7f": "Twila Tracey",
      "user_c1d462c8eba940f9bc76d3d88838bbfb": "Junita Joubert",
      "user_d2669ccf033f46c79b0adda40cf3383c": "Zana Zimmerman",
      "user_142da3c419804a82a3057cedc86acaa6": "Birdie Baldree",
      "user_8e92a37f342b482facd1eebbd782006a": "Carmina Corvin",
      "user_53bbe00387004010a8b9ad5f36bdd4a7": "Gertie Gibbon",
      "user_c1b2080663a94817868eefb6cac8e18e": "Karie Kivett",
      "user_eff1792e14a746b99b1e92950848772c": "Seth Stransky",
      "user_a67530c8d4ac4ab4a27a9e4b129bdda5": "Sol Steedley",
      "user_dce466f2ebf346168bae8c9024cc17f0": "Vanesa Voss",
      "user_912210948aa849eda2c3e0c2b58355e6": "Danna Delacruz",
      "user_a25f1a913867452594186bf056c9f165": "Rickie Roscoe",
      "user_6b48d96586784272abaf89bd15f90295": "Mason Morena",
      "user_a109e9b5d75349c6ab3c0daf5baa2198": "Quinn Quinby",
      "user_a7f0471fb9c64a00af7b3029234cff99": "Nathaniel Nestor",
      "user_159709bbbb534b579770539e0c7d5037": "Thea Twigg",
      "user_63ea15931d8541a3bd35e5b1f09087dc": "Adaline Appleberry",
      "user_6a535a77e2aa4a109373ac6670d6c2a3": "Marylee Metzgar",
      "user_aa51f0825ce24faa8bf66709c7d454c2": "Nobuko Nitta",
      "user_e017338080be4aa7898de218458ff2a5": "Kristina Korando",
      "user_2208f461810144cb8994ecc5136cc3ee": "Sophie Schock",
      "user_93e25fbcac7a4a9c9e5b0e8fa75ac673": "Hoa Hudec",
      "user_f4905c936732451b85fd82acc4c45bba": "Veola Vernon",
      "user_4205ea2b9cc549048d4b2e9da389c348": "Sally Southworth",
      "user_f04ca61de8ba44af8e50ed5bd37ff822": "Janeen Jefferson",
      "user_4e2f18aba20640cf922c8bc485941f8e": "Carlene Cruce",
      "user_fcde9d330a5d41a8b810de6cfacff64d": "Bertie Blomberg",
      "user_dfc0406700564f0797038bebeabb617f": "Mikki Mosher",
      "user_00505cca5b04460fafd716af48665ca1": "Leonardo Lukasik",
      "user_47557ad75d4047efab1b6577cec3efe7": "Bradley Brigman",
      "user_0149372b160544cf981b6284dd2b5e45": "Booker Burchfield",
      "user_fd92e551358e4af1b610cb9bafe39494": "Elin Emmanuel",
      "user_ffea0ad773f3424592e76f5108deaaaa": "Angelica Ates",
      "user_16cc89c2e06c497cb65930f0c4729dce": "Ronny Raffa",
      "user_e0e43601f93249c382415521188f0208": "Ardith Arbogast",
      "user_868e2d4ecf61494ea10140a00abdb0e5": "Lilli Longwell",
      "user_fb9ca56c8d3547268f2d589a6fcb1556": "Della Dority",
      "user_a204f87d215a409798be9fb207685f44": "Star Sletten"
    ]
  }()
}
