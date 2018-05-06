# 2013-2018 kojix2

# カードと鑑別疾患
class CardAndDiagnosis
  def initialize(dir)
    @reader = nil
    temp_path = (dir + '/diagnosis/diagnosis.csv')
    puts temp_path
    begin
      *@reader = CSV.read(temp_path)
    rescue StandardError
      @reader = []
    end

    window = TkToplevel.new(title: '鑑別疾患カード')

    # 左側のフレーム
    left_frame = TkFrame.new(window) do
      pack(side: :left, padx: 2, pady: 2)
    end

    # カードラベル
    TkLabel.new(left_frame) do
      text 'Cards'
      height 1
      font(size: 14)
      pack
    end

    left_listframe = TkFrame.new(left_frame).pack
    scr1 = TkScrollbar.new(left_listframe) do
      pack('fill' => 'y', 'side' => 'right')
    end
    @cardlist = TkListbox.new(left_listframe) do
      font TkFont.new('size' => '12')
      width 20
      height 20
      yscrollbar(scr1)
      pack
    end
    @cardlist.bind '<ListboxSelect>', proc { card_did_select(@cardlist.curselection) }

    @reader[1].compact.each do |h|
      @cardlist.insert('end', h)
    end

    # 右側のフレーム
    right_frame = TkFrame.new(window) do
      pack(side: :left, padx: 2, pady: 2)
    end

    # Diagnosis ラベル
    TkLabel.new(right_frame) do
      text 'Diagnosis'
      height 1
      font(size: 14)
      pack
    end

    right_listframe = TkFrame.new(right_frame).pack
    scr2 = TkScrollbar.new(right_listframe).pack('fill' => 'y', 'side' => 'right')
    @diagnosislist = TkListbox.new(right_listframe) do
      font TkFont.new('size' => '12')
      width 20
      height 20
      yscrollbar(scr2)
      pack
    end
    # @diagnosislist.bind '<ListboxSelect>', proc{ puts curselection }
  end

  # カードが選択されたとき
  def card_did_select(selectnum)
    @diagnosislist.clear
    @reader[2..-1].compact.each do |item|
      @diagnosislist.insert('end', item[selectnum[0]]) unless item[selectnum[0]].nil?
    end
    Tk.update(@diagnosislist)
  end
end
