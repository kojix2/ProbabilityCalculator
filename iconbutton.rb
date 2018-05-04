# 2013-2018 kojix2

# メインウィンドウ
class MainWindow
  # アイコンのボタン
  class IconButton
    def initialize(toolbar, dir, icon_name, help_text, _text = '', &block)
      frame = TkFrame.new(toolbar).pack(fill: :x, side: :left, padx: 2)
      @icon = Tk::BWidget::Button.new(frame)  do
        image TkPhotoImage.new(file: File.join(dir, "icons/#{icon_name}"))
        helptext help_text
        relief :flat
      end.pack
      @text = TkLabel.new(frame, text: _text, font: { size: 10 }).pack
      command(block) if block_given?
    end

    def command(cmd)
      @icon.command cmd
      @text.bind 'Button-1', cmd
    end
  end
end
