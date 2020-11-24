# 2013-2018 kojix2

# 継承元クラス
class Test
  attr_reader :name, :sensitivity, :specificity, :lr_positive, :lr_negative

  def initialize(name, sensitivity, specificity)
    @name = name
    @sensitivity = sensitivity
    @specificity = specificity
  end
end

# 計算を担当するクラス
class Calclator
  # 検査と結果をセットにしたクラス Test ＆ Result
  class TestR < Test
    attr_accessor :name, :result

    def initialize(test, result)
      # hashの使用をやめた時はココ書き直し
      @name = test[:examination].toutf8
      @sensitivity = test[:sensitivity].nil? ? nil : test[:sensitivity].to_f / 100.0
      @specificity = test[:specificity].nil? ? nil : test[:specificity].to_f / 100.0
      @lr_positive = test[:lr_positive].nil? ? nil : test[:lr_positive].to_f
      @lr_negative = test[:lr_negative].nil? ? nil : test[:lr_negative].to_f
      @result = result
    end
  end

  # 事前確率
  attr_accessor :prior_probability
  attr_reader :order, :probabilities

  def initialize(prior_probability = PRIOR_PROBABILITY_DEFAULT)
    @prior_probability = prior_probability # 0.5＝50％：換算注意
    @order = [] # Testedを入れる配列
    #    [{:examination=>"右下腹部痛", :sensitivity=>84, :specificity=>90}, :positive],
    #    [{:examination=>"筋性防御", :sensitivity=>73, :specificity=>52}, :negative}
    #    結果は、true, falseではなく、:positive, :negative, :neutral の3種類にする
    @probabilities = []
  end

  def result_probability
    @probabilities.last || @prior_probability
  end

  # 計算を実行する
  def exec(_num = 0)
    # 面倒なので初期化して毎回計算し直している
    @probabilities = []
    @order.each do |test|
      np = @probabilities.last || @prior_probability # now_probability
      if test.sensitivity && test.specificity # nilがないことを確認
        # 感度・特異度による計算を優先する
        puts "感度・特異度による計算:#{test.name}[#{test.result}]"
        case test.result
        when :positive # 結果が陽性の時
          rp = (np * test.sensitivity) / (np * test.sensitivity + ((1.0 - np) * (1.0 - test.specificity)))
        when :negative # 結果が陰性の時
          rp = (np * (1.0 - test.sensitivity)) / (np * (1.0 - test.sensitivity) + ((1.0 - np) * test.specificity))
        when :neutral # 中立
          rp = np
        else
          raise
        end
      elsif test.lr_positive && test.lr_negative # 一応こうしておく
        # 尤度比による計算
        puts "尤度比による計算:#{test.name}[#{test.result}]"
        case test.result
        when :positive
          odds = np / (1 - np) * test.lr_positive
          rp = odds / (1 + odds)
        when :negative
          odds = np / (1 - np) * test.lr_negative
          rp = odds / (1 + odds)
        when :neutral
          rp = np
        else
          raise
        end
      else
        rp = np
        Tk.messageBox(type: :ok, icon: :error, title: '計算エラー', message: '計算できません')
        break
      end
      @probabilities << rp
    end
    print @probabilities.map { |item| (item * 100).round(2).to_s << '％' }.to_s + "\n"
    puts '-計算END-'
  end

  # 検査オーダーの追加
  def add(test, result)
    @order << TestR.new(test, result)
  end

  # 場所を指定して検査オーダーの追加　#使いこなせない
  def add_at(num, test, result)
    @order[num, 0] = TestR.new(test, result)
  end

  # 検査が陽性
  def positive(num)
    @order[num].result = :positive
  end

  # 検査が陰性
  def negative(num)
    @order[num].result = :negative
  end

  # 検査が中立
  def neutral(num)
    @order[num].result = :neutral
  end

  # 検査オーダーの削除
  def delete(num)
    @order.delete_at(num)
    @probabilities = []
  end

  # 初期化
  def clear
    @prior_probability = PRIOR_PROBABILITY_DEFAULT
    @probabilities = []
    @order = []
  end
end
