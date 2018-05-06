# 2013-2018 kojix2

# メインウィンドウ
class MainWindow
  def initialize(data, preprobability_data, guidelines_data, dir)
    # 基本のディレクトリ
    @dir = dir
    # 全データ(Hash)
    @exams = data
    # 事前確率データ
    @preprobability_text = preprobability_data
    # ガイドラインデータ
    @guidelines = guidelines_data
    # 計算のためのクラス
    @calc = Calclator.new
    puts '＜Calclatorインスタンスを作成しました＞'
    root = TkRoot.new(title: TITLE)

    @tkOrder = []
    _create(root)
    _set_condition
  end

  # GUI作成をinitializeから分離
  def _create(root)
    dirname = @dir

    # メニューバー
    menubar = TkMenu.new(root)
    root.menu(menubar)
    file, view, wind, help = Array.new(4) { TkMenu.new(menubar, tearoff: false) }

    menubar.add :cascade, menu: file, label: 'ファイル'
    file.add :command, label: '計算クリア', command: proc { @calc.clear; remove_all_test_order }
    file.add :command, label: '終了', command: proc { exit }

    menubar.add :cascade, menu: view, label: '表示'
    view.add :command, label: '標準ツールバーを非表示', command: proc { @standard_toolbar.unpack }
    view.add :command, label: '標準ツールバーを表示', command: proc { @standard_toolbar.pack(side: :left) }

    menubar.add :cascade, menu: wind, label: 'ウィンドウ'
    wind.add :command, label: '常に前面で表示', command: proc { root.attributes(topmost: 1) }
    wind.add :command, label: '常に前面で表示を解除', command: proc { root.attributes(topmost: 0) }
    wind.add :command, label: '鑑別疾患を表示', command: proc { CardAndDiagnosis.new(dirname) }

    menubar.add :cascade, menu: help, label: 'ヘルプ'
    help.add :command, label: '簡単な使い方', command: proc { HelpWindow.new(dirname) }
    help.add :command, label: 'バージョン情報', command: proc { VersionDialog.new }

    # ツールバー
    toolbarframe = TkFrame.new(root) do
      borderwidth 1
      relief :groove
      pack(side: :top, fill: :x)
    end

    # 標準ツールバー
    @standard_toolbar = TkFrame.new(toolbarframe) do
      borderwidth 1
      relief :raised
      pack(side: :left)
    end

    # 鑑別疾患リストボタン作成
    IconButton.new(@standard_toolbar,
                   @dir,
                   'cardgame32.png',
                   '鑑別診断カードを参照する',
                   '鑑別') do
                     CardAndDiagnosis.new(@dir)
                   end

    # 新規アイコンボタン作成
    IconButton.new(@standard_toolbar,
                   @dir,
                   'paper32.png',
                   '検査履歴をクリアする',
                   'クリア') do
                     @calc.clear; remove_all_test_order
                   end

    # 実行アイコンボタン作成
    IconButton.new(@standard_toolbar,
                   @dir,
                   'circleright32.png',
                   '強制的に計算を実行する',
                   '計算') do
                     @calc.exec; show_values
                   end

    # グラフ作成
    IconButton.new(@standard_toolbar,
                   @dir,
                   'bargraph32.png',
                   '検査特性グラフを別ウィンドウで表示する',
                   'グラフ') do
                     if @conditionList.selection_get[0].nil?
                       Tk.messageBox(title: 'エラー', message: 'CONDITIONを選択してね')
                     else
                       condition = get_condition
                       BoxChart.new(@exams[condition], condition, false)
                     end
                   end

    # CSVファイルを再読み込みボタン作成
    IconButton.new(@standard_toolbar,
                   @dir,
                   'exchange32.png',
                   'DATA再度読み込み：未実装',
                   '更新') do
                     Tk::BWidget::MessageDlg.new(relative: Tk.root,
                                                 message: '未実装です。すみません。').create
                   end

    # メッセージ表示
    IconButton.new(@standard_toolbar,
                   @dir,
                   'lightbulb32.png',
                   '簡単な使い方を表示する',
                   '使い方') do
                     HelpWindow.new(dirname)
                   end

    # ステータスバー
    TkFrame.new(root) do |statusbar|
      borderwidth 1
      relief :flat
      pack(side: :bottom, fill: :x)
      Tk::BWidget::Separator.new(statusbar) do
        orient :horizontal
        pack(side: :top, fill: :x)
      end
      TkLabel.new(statusbar) do
        text '2014　kojix2'
        pack
      end
    end

    # 全体のパネルウィンドウ
    pw_main = Tk::Tile::Paned.new(root, orient: :horizontal)
    side_pane = TkFrame.new(pw_main) do
      width 400
      pack
    end
    contents_pane = TkFrame.new(pw_main) do
      width 400
      pack
    end
    pw_main.add side_pane
    pw_main.add contents_pane

    # 左側のパネル
    pw_left = Tk::Tile::Paned.new(side_pane, orient: :vertical)
    information_pane = TkFrame.new(pw_left, height: 200).pack
    view_pane = TkFrame.new(pw_left, height: 60).pack
    pw_left.add information_pane
    pw_left.add view_pane

    @first_notebook = Tk::Tile::Notebook.new(information_pane) do
      height 250
      width 390
      pack(fill: :both, expand: true)
    end
    browser_view_pane, guideline_view_pane = Array.new(2) { TkFrame.new(@first_notebook) }
    @first_notebook.add(browser_view_pane, text: 'ファインダ')
    @first_notebook.add(guideline_view_pane, text: 'ガイドライン')
    @first_notebook.select browser_view_pane

    # CONDITIONフレーム
    condition_frame = TkFrame.new(browser_view_pane) do
      height 400
      pack(side: :left, fill: :both, expand: true)
    end
    # TESTフレーム
    test_frame = TkFrame.new(browser_view_pane) do
      height 400
      pack(side: :left, fill: :both, expand: true)
    end

    # CONDITIONラベル
    TkLabel.new(condition_frame) do
      text 'CONDTION'
      width 20
      height 1
      pack(padx: 1, pady: 2, side: :top, fill: :x)
    end

    # TESTラベル
    TkLabel.new(test_frame) do
      text 'TEST（ダブルクリックで追加）'
      width 22
      height 1
      pack(padx: 1, pady: 2, side: :top, fill: :x)
    end

    # CONDITION リストボックス
    sw1 = Tk::BWidget::ScrolledWindow.new(condition_frame)
    @conditionList = Tk::BWidget::ListBox.new(sw1) do
      height 15
      width 15
      bg :white
      selectmode :single
    end
    sw1.set_widget(@conditionList)
    sw1.pack(fill: :both, expand: true)

    # TEST リストボックス
    sw2 = Tk::BWidget::ScrolledWindow.new(test_frame)
    @examList = Tk::BWidget::ListBox.new(sw2) do
      height 15
      width 20
      bg :white
      selectmode :single
    end
    sw2.set_widget(@examList)
    sw2.pack(fill: :both, expand: true)

    # ガイドラインパネル
    g_f = Tk::BWidget::TitleFrame.new(guideline_view_pane, text: '検索').pack(fill: :x).get_frame
    TkEntry.new(g_f, textvariable: TkVariable.new('dummy'), state: :readonly).pack(side: :left, expand: true, fill: :x)
    Tk::Tile::Button.new(g_f, text: 'クリア').pack(side: :right, padx: 2)
    Tk::Tile::Button.new(g_f, text: '検索').pack(side: :right, padx: 2)
    @guidelinetree = Ttk::Treeview.new(guideline_view_pane).pack(fill: :both)
    @guidelinetree.columns = %i[type path]
    @guidelinetree.heading_configure(:type, text: '種類')
    @guidelinetree.column_configure(:type, width: 30)
    @guidelinetree.heading_configure(:path, text: '場所')
    @guidelinetree.bind 'Double-1', proc { open_file }
    @guidelines.each do |key, value|
      department = @guidelinetree.insert(nil, :end, text: key)
      value.each do |item|
        @guidelinetree.insert(department, :end, text: item[:title], value: [item[:type], item[:path]])
        # (@guidelinetree.children department).each {|item| pp item.value} するとおかしい。tcl/tkの仕様？Rubyのバグ？
      end
    end

    # 検査の詳細フレーム
    @notebook = Tk::Tile::Notebook.new(view_pane) do
      height 250
      width 390
      pack(fill: :both, expand: true)
    end

    preprob_view_pane, note_view_pane = Array.new(2) { TkFrame.new(@notebook) }
    @notebook.add(preprob_view_pane, text: '事前確率')
    @notebook.add(note_view_pane, text: 'データ')

    @notebook.select note_view_pane
    w4 = Tk::BWidget::ScrolledWindow.new(note_view_pane)
    sf4 = Tk::BWidget::ScrollableFrame.new(w4, constrainedwidth: true)
    w4.set_widget(sf4)
    w4.pack(fill: :both, expand: true)
    view_frame = sf4.get_frame
    view_frame.configure(bg: :white, borderwidth: 1, relief: :groove)

    # データ表示部
    @title_var = TkVariable.new
    @sensitivity_var = TkVariable.new
    @specificity_var = TkVariable.new
    @lrp_var = TkVariable.new
    @lrm_var = TkVariable.new
    @lrm_bar_var = TkVariable.new
    @memo_var = TkVariable.new
    @source_var = TkVariable.new

    # タイトル
    titleLabel = TkLabel.new(view_frame, textvariable: @title_var) do
      bg :white
      anchor :sw
      font(size: 11, weight: :bold)
      pack(padx: 8, pady: 8, fill: :x)
    end
    # gridするためのフレーム
    data_frame = TkFrame.new(view_frame) do
      bg :white
      pack(fill: :both)
    end

    # GRID
    %w[感度 特異度 LR+ LR- メモ 出典].each_with_index do |_text, idx|
      TkLabel.new(data_frame) do
        text _text
        bg :white
        grid(row: idx, column: 0, sticky: :e, padx: 8, pady: 4)
      end
    end

    [@sensitivity_var, @specificity_var, @lrp_var, @lrm_var].each_with_index do |var, idx|
      TkLabel.new(data_frame, textvariable: var) do
        bg :white
        width 4
        grid(row: idx, column: 1, sticky: :w, padx: 8, pady: 4)
      end
    end

    [@sensitivity_var, @specificity_var].zip([WINRED, WINGREEN]).each_with_index do |arr, idx|
      var, color = *arr
      Tk::BWidget::ProgressBar.new(data_frame) do
        height 12
        foreground color
        troughcolor :white
        bg :white
        variable var
        maximum 100
        grid(row: idx, column: 2)
      end
    end

    [@lrp_var, @lrm_bar_var].zip([WINORANGE, WINPURPLE]).each.with_index(2) do |arr, idx|
      var, color = *arr
      Tk::BWidget::ProgressBar.new(data_frame) do
        height 12
        foreground color
        troughcolor :white
        bg :white
        variable var
        maximum 10
        grid(row: idx, column: 2)
      end
    end

    [@memo_var, @source_var].each.with_index(4) do |var, idx|
      TkLabel.new(data_frame, textvariable: var) do
        bg :white
        grid(row: idx, column: 1, columnspan: 2, sticky: :w, padx: 8, pady: 4)
      end
    end

    # preprobの詳細
    @preprob_tktext = TkText.new(preprob_view_pane) do
      font ({ size: 10 })
      pack(fill: :both)
    end

    #  @preprob_tktext.insert :end, "工事中"
    @preprob_tktext.state :disabled

    # コンテンツの詳細フレーム
    @main_notebook = Tk::Tile::Notebook.new(contents_pane) do
      height 500
      width 450
      pack(fill: :both, expand: true)
    end

    @graph_nb, contents_pane_nb, @table_nb = Array.new(3) { TkFrame.new(@main_notebook) }
    @main_notebook.tap do |mn|
      mn.add(@graph_nb, text: 'グラフ')
      mn.add(@table_nb, text: 'テーブル')
      mn.add(contents_pane_nb, text: '計算機')
      mn.select 0
    end
    @title_frame = TkLabel.new(contents_pane_nb) do
      height 1
      text '左からCONDITIONを選択してTESTを追加して下さい'
      pack(pady: 2, side: :top, fill: :x)
    end

    # 事前確率のフレーム
    pre_probability_frame = TkFrame.new(contents_pane_nb) do
      pack(side: :top, fill: :x, padx: 5)
    end
    @tk_pre_probability = TkVariable.new('50')

    # 事前確率
    b = TkButton.new(pre_probability_frame) do
      text '事前確率'
      font(size: 12)
      relief :raised
      borderwidth 1
      pack(side: :left)
    end
    b.command { @notebook.select 0 }

    # 事前確率％ラベル
    TkLabel.new(pre_probability_frame) do
      text '％'
      font(size: 14)
      pack(side: :right)
    end
    TkLabel.new(pre_probability_frame, textvariable: @tk_pre_probability) do
      font(weight: :bold, size: 16)
      pack(side: :right)
    end

    # 事前確率スケール
    pre_scale = TkScale.new(pre_probability_frame,
                            variable: @tk_pre_probability) do
      orient :horizontal
      width 5
      length 280
      showvalue false
      from 0
      to 100
      pack(side: :right)
    end
    Tk::BWidget::Separator.new(contents_pane_nb) do
      orient :horizontal
      pack(fill: :x)
    end

    # 事前確率スケールが変更された時、@calcに教える
    pre_scale.bind 'ButtonRelease-1', proc {
      @calc.prior_probability = @tk_pre_probability.value.to_f / 100.0
      @calc.exec
      show_values
    }

    # コンテンツフレーム
    w3 = Tk::BWidget::ScrolledWindow.new(contents_pane_nb, bg: :gray98)
    sf3 = Tk::BWidget::ScrollableFrame.new(w3, constrainedwidth: true, bg: :gray98)
    w3.set_widget(sf3)
    w3.pack
    @content_frame = sf3.get_frame
    @content_frame.configure(width: 400)
    # ScrolledWindowsとScrollableFrameの違いがわからない

    w3.pack(fill: :both, expand: :true)

    # 最終確率のセパレータ
    Tk::BWidget::Separator.new(contents_pane_nb) do
      orient :horizontal
      pack(side: :top, fill: :x)
    end

    # 最終確率のフレーム
    result_probability_frame = TkFrame.new(contents_pane_nb) do
      relief :raised
      height 3
      pack(side: :top, padx: 5, fill: :x)
    end
    @tk_result_probability = TkVariable.new

    # 最終確率のラベル
    TkLabel.new(result_probability_frame) do
      text '最終確率：'
      font(size: 12)
      pack(side: :left)
    end

    # 最終確率の%ラベル
    TkLabel.new(result_probability_frame) do
      text '％'
      font(size: 14)
      pack(side: :right)
    end

    TkLabel.new(result_probability_frame,
                textvariable: @tk_result_probability) do
      font(weight: :bold, size: 16)
      pack(side: :right)
    end

    # 最終確率のスケール
    result_scale = TkScale.new(result_probability_frame,
                               variable: @tk_result_probability) do
      orient :horizontal
      width 5
      length 280
      showvalue false
      from 0
      to 100
      pack(side: :right)
    end

    Tk.pack(pw_main, pw_left, condition_frame, test_frame, fill: :both, expand: true)

    # 表タブを作る
    f = TkFrame.new(@table_nb) do
      pack(fill: :x)
    end
    contena = Ttk::Frame.new(@table_nb)
    @table = Tk::Tile::Treeview.new(@table_nb) do
      show :headings
      pack(fill: :both, expand: true)
    end
    @table.columns = 'name sensitivity specificity lr_positive lr_negative'
    @table.columns.zip(%w[検査名 感度 特異度 LR＋ LR?]).each do |col, name|
      @table.heading_configure(col, text: name)
      next if col == 'name'
      @table.column_configure(col, width: 50)
    end
    vsb = @table.yscrollbar(TkScrollbar.new(@table_nb))
    contena.pack(fill: :both, expand: true)
    Tk.grid(@table, vsb, in: contena, sticky: 'nsew')
    contena.grid_columnconfigure(0, weight: 1)
    contena.grid_rowconfigure(0, weight: 1)

    # グラフタブ
    #    temp_image = TkPhotoImage.new(file:File.join(@dir, "icons/kimitsu.png"))
    #    @kimitsu_chuo_hospital = TkLabel.new(f, image:temp_image).pack(side: :bottom)
    @kimitsu_chuo_hospital = TkLabel.new(@graph_nb) do
      text 'CONDITIONを選択してグラフを描出できます。'
      wraplength 400
      pack
    end
  end

  # ファイルを開く
  def open_file
    path = @guidelinetree.selection[0].value[1]
    pp path
    if RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/ # Windows判定
      system("start #{path.gsub(/\//) { '\\' }}") unless path.nil? || path.empty?
    elsif RUBY_PLATFORM.downcase =~ /darwin/ # Mac判定
      system("open #{path.join(' ').shellescape}") # 
    else
      begin
        system "xdg-open #{path}"
      rescue
        Tk.messageBox(title: "#{RUBY_PLATFORM}ユーザーですか？", message: "申し訳ありませんがファイルを開けません。\n#{path}")
      end
    end
  end

  # Condition リストボックスに要素を追加する
  def _set_condition
    # CONDITIONの項目を追加する
    folder_image = Tk::BWidget::Bitmap.new('folder')
    @exams.keys.each do |condition|
      @conditionList.insert :end, condition, text: condition, image: folder_image
    end
    @conditionList.bind 'Return', proc {
      condition = get_condition
      _set_test condition
      @calc.clear
      remove_all_test_order
      plot_graph
      show_table
    }
    @conditionList.bind 'Button-1', proc {
      condition = get_condition
      break if condition.nil?
      _set_test condition
      @calc.clear
      remove_all_test_order
      plot_graph
      show_table
    }

    @examList.bind '<ListboxSelect>', proc { show_info }
    @examList.textbind 'Double-1', proc { add_test_order }
    @examList.imagebind 'Double-1', proc { add_test_order }
    @examList.bind 'Return', proc { add_test_order }
  end

  # Test リストボックスに要素を追加する+事前確率欄更新
  def _set_test(hoge)
    @examList.delete @examList.items
    file_imgae = Tk::BWidget::Bitmap.new('file')

    @exams[hoge].each_with_index do |exam, _i|
      _text = exam[:examination]
      @examList.insert :end, _text, text: _text, image: file_imgae
    end
    @title_frame.text = get_condition + ' の 診療履歴'
    # 表示遅延対策
    Tk.update

    @preprob_tktext.state :normal
    @preprob_tktext.value = @preprobability_text[hoge] || 'データなし'
    @preprob_tktext.state :disabled
  end

  def get_condition
    @conditionList.selection_get[0].encode("utf-8")
  end

  def get_exam_num
    @examList.index(@examList.selection_get).to_i
  end

  # 感度や特異度の情報を表示する
  def show_info
    condition = get_condition
    num = get_exam_num
    @notebook.select 1
    @title_var.value = @exams[condition][num][:examination]
    @sensitivity_var.value = (@exams[condition][num][:sensitivity] || '-')
    @specificity_var.value = (@exams[condition][num][:specificity] || '-')
    @lrp_var.value = (@exams[condition][num][:lr_positive] || ' - ')
    # 表示のための小細工
    lrm_var_temp = unless @exams[condition][num][:lr_negative].nil?
                     1.0 / @exams[condition][num][:lr_negative].to_f
                   end
    @lrm_var.value = (@exams[condition][num][:lr_negative] || ' - ')
    @lrm_bar_var.value = lrm_var_temp
    @memo_var.value = (@exams[condition][num][:memo] || '')
    @source_var.value = (@exams[condition][num][:source] || '')
  end

  # 検査をを追加する
  def add_test_order
    # 詳細を表示
    show_info
    condition = get_condition
    i = get_exam_num

    @main_notebook.select 2
    # 計算クラスのインスタンスに、neutralで検査を追加
    @calc.add @exams[condition][i], :neutral

    # GUIのためのクラスを作成して、配列に詰め込む＋自分自身の番号情報を持たせる
    length = @tkOrder.length
    @tkOrder << TkTest.new(@content_frame, @exams[condition][i], :neutral, self, length).create_gui
  end

  # 検査の削除
  def remove_test_order(num)
    # GUIの削除
    @tkOrder[num].delete
    # 配列からも削除
    @tkOrder.delete_at num
    # 番号再確認
    @tkOrder.each_with_index do |test, index|
      test.number = index
    end
    # calcの削除
    @calc.delete num
    @calc.exec
    show_values
  end

  def remove_all_test_order
    @tkOrder.each(&:delete)
    @tkOrder = []
    @tk_pre_probability.value = 50
    @tk_result_probability.value = 50
  end

  # 陽性・陰性が変更された時
  def result_changed(num, val)
    # TkVariableの中にシンボルを入れると文字列になるらしい
    @calc.send(val, num)
    @calc.exec # 計算を実行
    show_values
  end

  def show_values
    @calc.probabilities.each_with_index do |item, index|
      item = (item * 100).round(0)
      @tkOrder[index].probability = item
    end
    @tk_result_probability.value = (@calc.result_probability * 100).round(0)
  end

  # グラフを描出する
  def plot_graph
    begin
      @kimitsu_chuo_hospital.destroy
      #      temp_image.delete
    rescue StandardError
    end
    begin
      @graph.destroy
    rescue StandardError
      puts '初めてのグラフを描出します'
    end
    if @conditionList.selection_get[0].nil?
      Tk.messageBox(title: 'エラー', message: 'CONDITIONを選択してね')
    else
      condition = get_condition
      num = get_exam_num
      @graph = BoxChart.new(@exams[condition], condition, @graph_nb)
    end
  end

  # テーブルを描出する
  def show_table
    begin
      @table.delete(@table.children(''))
    rescue StandardError
      puts 'table存在しないようです'
    end
    if @conditionList.selection_get[0].nil?
      Tk.messageBox(title: 'エラー', message: 'CONDITIONを選択してね')
    else
      @exams[get_condition].each_with_index do |item, index|
        data = [item[:examination],
                item[:sensitivity],
                item[:specificity],
                item[:lr_positive],
                item[:lr_negative]]
        if index.odd?
          @table.insert nil, :end, value: data, tags: 'odd'
        else
          @table.insert nil, :end, value: data
        end
        @table.tag_configure('odd', background: WINBLUE)
      end
    end
    Tk.update @table
  end
end
