# 2013-2018 kojix2
class MainWindow
  # ヘルプを表示するウィンドウ
  class HelpWindow
    def initialize(dir)
      puts 'show_help' # コンソール出力

      begin
        filepath = File.join(dir, 'help/use.txt')
        s = File.read(filepath, encoding: 'UTF-8:UTF-8')
      rescue StandardError
        s =  "ヘルプファイルが見つかりませんでした\n"
        s << File.join(dir, 'use.txt')
      end

      help_window = TkToplevel.new(title: "#{TITLE} ヘルプ")

      # タイトル
      TkLabel.new(help_window) do
        text '簡単な使い方'
        font(size: 12)
        pack(padx: 5, pady: 5)
      end

      # スクロールバー
      _scr = TkScrollbar.new(help_window) do
        pack(fill: :y, side: :right)
      end

      # テキスト表示エリア
      _text = TkText.new(help_window) do
        width 60
        height 20
        padx 10
        pady 10
        spacing1 4
        spacing2 8
        spacing3 4
        yscrollbar(_scr)
        pack(side: :right, padx: 3, pady: 3, fill: :both, expand: true)
      end
      _text.insert :end, s
      _text.state :disabled # 編集禁止にする
      _text.focus
    end
  end
end
