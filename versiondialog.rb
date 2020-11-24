# frozen_string_literal: true

# 2013-2018 kojix2

class MainWindow
  class VersionDialog
    def initialize
      puts 'show_version'
      msgbox = Tk.messageBox(
        type: :ok,
        icon: :info,
        title: 'バージョン情報',
        message: "#{TITLE} \n\n  2013-2018\n kojix2"
      )
    end
  end
end
