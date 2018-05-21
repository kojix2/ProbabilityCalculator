
  # ファイルを開く
  def open_file
    path = @guidelinetree.selection[0].value[1]
    pp path
    if RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/ # Windows判定
      system("start #{path.gsub(/\//) { '\\' }}") unless path.nil? || path.empty?
    elsif RUBY_PLATFORM.downcase =~ /darwin/ # Mac判定
      system("open #{path}") #
    else
      begin
        system "xdg-open #{path}"
      rescue StandardError
        Tk.messageBox(
          title: "#{RUBY_PLATFORM}ユーザーですか？",
          message: "申し訳ありませんがファイルを開けません。\n#{path}"
        )
      end
    end
  end
