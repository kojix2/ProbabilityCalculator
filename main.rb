# 2013-2018  kojix2

require 'pp'
require 'shellwords'
require 'kconv'
require 'csv'
require 'tk'
require 'tkextlib/bwidget'
require 'tkextlib/tkimg/png'
require 'tkextlib/tcllib/plotchart'

require_relative 'calculator'
require_relative 'cardanddiagnosis'
require_relative 'boxchart'
require_relative 'mainwindow'
require_relative 'tktest'
require_relative 'iconbutton'
require_relative 'helpwindow'
require_relative 'versiondialog'

VERSION = 2.0
TITLE = " ベイズの旧式確率計算機 あるいは 感度・特異度ブラウザ #{VERSION}".freeze

# 事前確率デフォルト値
PRIOR_PROBABILITY_DEFAULT = 0.5
WINRED = :red # "#C75B55"
WINGREEN = :green # "#A1BD61"
WINORANGE = :yellow # "#FA9D4D"
WINPURPLE = :blue # "#886FA8"
WINBLUE = :skyblue # "#558AC2"

# OCRA関連
if ENV.key?('OCRA_EXECUTABLE')
  # ここは EXE ファイル実行中のみ通る
  dir = '' # ：OCRAで使用するときにディレクトリを指定
  puts '<OCRA で実行>'
else
  dir = File.join(Dir.pwd, 'Contents')
  puts '<NO OCRA で実行>'
end

# データはHASHと配列
# フォルダ以下のCSVファイルを読み込むようにする
data = {}

# 感度・特異度データ読み込み
def read_data_files(dir)
  data = {}
  csv_files = Dir.glob(File.join(dir, '*.csv'))

  csv_files.each do |csv|
    puts csv # ファイルの名前を出力
    exam = []
    # 内部エンコーディングはUTF-8
    name = File.basename(csv, '.*')
    begin
      # Shift_JIS指定
      CSV.foreach(csv, headers: true, header_converters: :symbol) do |row|
        exam << Hash[row.headers[0..-1].zip(row.fields[0..-1])]
      end
      data.store(name, exam)
    rescue StandardError
      Tk.messageBox(type: :ok, icon: :error, title: 'CSV読み込みエラー', message: "#{name}の読み込み中にエラーが発生しました。")
    end
  end

  data
end

# 事前確率データ読み込み
def read_preprobability_data_files(dir)
  data = {}
  txts = Dir.glob(File.join(File.join(dir, 'pre_probability'), '*.txt'))

  txts.each do |filepath|
    puts filepath # ファイルの名前を出力
    name = File.basename(filepath, '.*')
    begin
      text = File.read(filepath)
      data.store(name, text)
    rescue StandardError
      Tk.messageBox(type: :ok, icon: :error, title: 'TXT読み込みエラー', message: "#{name}の読み込み中にエラーが発生しました。")
    end
  end

  data
end

# ガイドラインデータ読み込み
def read_guidlines(dir)
  data = {}
  # フォルダのみにする
  folders_path = Dir.glob(File.join(File.join(dir, 'guidelines'), '*/'))
  p folders_path
  folders_path.each do |path|
    puts path
    name = File.basename(path, '.*')
    files = Dir.glob(File.join(path, '*.*'))
    temparr = []
    files.each do |filepath|
      puts filepath
      temp = {}
      temp[:title] = File.basename(filepath, '.*')
      temp[:type] = File.extname(filepath)[1..-1] # ドット除去
      temp[:path] = filepath
      temparr << temp
    end
    data[name] = temparr
  end

  data
end

# pp data

def start_window(dir)
  puts '＜データを読み込んでいます…＞'
  data = read_data_files(dir)
  puts '＜事前確率情報を読み込んでいます…＞'
  preprobability_data = read_preprobability_data_files(dir)
  puts '＜ガイドラインを読み込んでいます…＞'
  guidelines_data = read_guidlines(dir)
  puts '＜ViewControllerのインスタンスを作成します…＞'
  mw = MainWindow.new(data, preprobability_data, guidelines_data, dir)
end

start_window(dir)

puts '＜Tk メインループを開始します＞'
Tk.mainloop
