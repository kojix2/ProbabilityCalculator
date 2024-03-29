# ベイズの旧式確率計算機 または 感度・特異度ブラウザ

[![DOI](https://zenodo.org/badge/132083398.svg)](https://zenodo.org/badge/latestdoi/132083398)

## これはなに？

感度・特異度から疾患の確率を計算するソフトです。

![screenshot1](http://medfreak.info/wp/wp-content/uploads/2016/08/bayes0.png)
![screenshot2](http://medfreak.info/wp/wp-content/uploads/2016/08/bayes1.png)
![screenshot3](http://medfreak.info/wp/wp-content/uploads/2016/08/diagnosis.png)

## 実用品ですか？

いいえ、ちがいます。
このようなツールは昔から提案されています。実際にあったら、どのようなことを感じるか。また、どこにボトルネックが生じるかを個人的に、検証・観察する目的で2013年頃に作成しました。未実装の機能やバグがあります。

## 鑑別診断について

鑑別疾患は medtoolz著、レジデント初期研修用資料 内科診療ヒントブック の目次から借用しています（文章量は多くありませんが、筆者が独自の工夫を凝らした部分であり、著作権の問題はあるかもしれません。レジデント初期研修用資料 内科診療ヒントブックは、類書の少ない名著であり、作者の卓越した能力によって暗黙知を文章化することに成功しています。私は旧版新版合計4冊購入しました。）

## 誰に見てほしいの？

プログラムが好きで、次世代のAIを作成したいと思っている研修医です。このツールには多くの難点がありますが、Automatorから着想を得たGUIのコンセプトは比較的うまくできていると思います。なぜこのようなツールは世代を超えて繰り返し発明れるのに、結果的にワークしないことが多いのか。それを乗り越えるにはどうすればよいのかを考えてもらいたくて、そのヒントになれば幸いです。

## インストールのヒント

Ruby/Tk を使用しています。機能の割にインストールが面倒なので、スクリーンショットから雰囲気を感じ取ってもらえれば十分だと思いますが、どうしてもインストールしたい人がいましたら、各種Webの情報を参照してRuby/Tk環境を導入してください。

### Ubuntu

```
sudo apt install tklib bwidget
gem install tk -- --with-tcltkversion=8.6 \
--with-tcl-lib=/usr/lib/x86_64-linux-gnu \
--with-tk-lib=/usr/lib/x86_64-linux-gnu \
--with-tcl-include=/usr/include/tcl8.6 \
--with-tk-include=/usr/include/tcl8.6 \
--enable-pthread
ruby main.rb
```

### Mac

ActiveStatesのTclをインストールしてからTk gemをインストールするのが無難なようです。

### Windows

なるべく文字コードをUTF-8に統一していますが、Windows-31jによるトラブルが生じる場合があります。
拡張ライブラリについては、SorceForge等から32bit, 64bitに注意しながら、Tcllib, Bwidgetなどをダウンロードして、RubyをインストールしているフォルダのTclのフォルダ内に直接配置すると認識します。
