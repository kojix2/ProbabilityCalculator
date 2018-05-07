ベイズの旧式確率計算機 または 感度・特異度ブラウザ
===

## これはなに？
感度・特異度から疾患の確率を計算するソフトです。

![screenshot1](http://medfreak.info/wp/wp-content/uploads/2016/08/bayes0.png)
![screenshot2](http://medfreak.info/wp/wp-content/uploads/2016/08/bayes1.png)
![screenshot3](http://medfreak.info/wp/wp-content/uploads/2016/08/diagnosis.png)

## 実用品ですか？
いいえ、ちがいます。
このようなツールは昔から提案されています。実際にあったら、どのようなことを感じるか。また、どこにボトルネックが生じるかを個人的に、検証・観察する目的で2013年頃に作成しました。未実装の機能やバグがあります。

## 誰に見てほしいの？
プログラムが好きで、次世代のAIを作成したいと思っている研修医です。このツールには多くの難点がありますが、Automatorから着想を得たGUIのコンセプトは比較的うまくできていると思います。

## インストールのヒント
Ruby/Tk を使用しています。Ruby/Tk環境の導入に関する情報は少ないですが、各種Webの情報を参照してください。
### Linux
plotchart を[一部修正](http://5zalt.hatenablog.com/entry/2014/11/22/170206)する必要があるようです。
### Mac
ActiveStatesのTclをインストールしてからTk gemをインストールするのが無難なようです。
### Windows
なるべく文字コードをUTF-8に統一していますが、Windows-31jによるトラブルが生じる場合があります。
拡張ライブラリについては、SorceForge等から32bit, 64bitに注意しながら、Tcllib, Bwidgetなどをダウンロードして、RubyをインストールしているフォルダのTclのフォルダ内に直接配置すると認識します。

## ツールを公開しませんか
ぜひあなたの作ってるツールを公開してください。
