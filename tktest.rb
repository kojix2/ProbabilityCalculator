# frozen_string_literal: true

# 2013-2018 kojix2

class MainWindow
  # 検査リストGUI作成のためのネストクラス
  class TkTest
    attr_accessor :number # 検査オーダーの番号情報を持つ

    def initialize(parent_widget, test, result, order, num)
      # 親ウィジェット
      @parent = parent_widget
      @name = test[:examination]
      @sensitivity = test[:sensitivity].to_i # ％表記
      @specificity = test[:specificity].to_i # ％表記
      @lr_positive = test[:lr_positive].to_f.round(3)
      @lr_negative = test[:lr_negative].to_f.round(3)
      @result = TkVariable.new(result)
      @holder = order
      @number = num
      @probability = TkVariable.new(0)
    end

    # GUI作成メソッド
    def create_gui
      # 検査全体のフレーム
      @test_frame = TkFrame.new(@parent) do
        relief :flat
        borderwidth 1
        pack(fill: :x, padx: 10, pady: 5)
      end

      # タイトルのフレーム
      test_title_frame = TkFrame.new(@test_frame) do
        bg :gray88
        borderwidth 1
        pack(fill: :x, expand: true)
      end

      # タイトルのラベル
      TkLabel.new(test_title_frame,
                  text: @name) do
        font(weight: :bold, size: 10)
        bg :gray88
        height 1
        pack(side: :left)
      end

      # タイトルの削除[X]ボタン
      test_title_delete_button = TkButton.new(test_title_frame) do
        bg :gray90
        text '×'
        relief :groove
        pack(side: :right)
      end
      # deleteボタンが押されたら親に問い合わせ
      test_title_delete_button.command { @holder.remove_test_order number }

      # 内容のフレーム
      test_content_frame = TkFrame.new(@test_frame) do
        bg :gray99
        pack(fill: :x, expand: true)
      end

      # 感度や特異度などのラベル
      test_content_label = TkLabel.new(test_content_frame) do
        bg :gray99
        height 2
        pack(side: :left)
      end
      test_content_label.text =
        "感度：#{@sensitivity}％　" \
        "特異度：#{@specificity}％　" \
        "LR+：#{@lr_positive}　" \
        "LR-：#{@lr_negative}"

      # 「陰性」のラジオボタン
      rbn = TkRadioButton.new(test_content_frame,
                              variable: @result) do
        text '陰性'
        value :negative
        bg :gray99
        pack(side: :right)
      end
      rbn.deselect # チェック外す

      # 「陽性」のラジオボタン
      rbp = TkRadioButton.new(test_content_frame,
                              variable: @result) do
        text '陽性'
        value :positive
        bg :gray99
        pack(side: :right)
      end
      rbp.deselect # チェック外す

      # ラジオボタンが押されたら親ウィジェットに問い合わせ
      rbn.command { @holder.result_changed @number, result }
      rbp.command { @holder.result_changed @number, result }

      test_arrow_frame = TkFrame.new(@test_frame) do
        bg :white
        pack(fill: :x, expand: true)
      end

      # 中途確率を表すプログレスバー
      Tk::BWidget::ProgressBar.new(test_arrow_frame,
                                   variable: @probability) do
        width 300
        height 15
        foreground WINBLUE
        bg :white
        troughcolor :white
        maximum 100
        pack(side: :left, padx: 2)
      end

      # 中途確率ラベル
      TkLabel.new(test_arrow_frame) do
        bg :white
        text '中途確率：'
        pack(side: :left)
      end

      # 中途確率の％表示
      TkLabel.new(test_arrow_frame,
                  textvariable: @probability) do
        bg :white
        pack(side: :left)
      end

      # "％" のラベル
      TkLabel.new(test_arrow_frame) do
        bg :white
        text '％'
        pack(side: :left)
      end

      self # できたウィジェットを親に返す
    end

    def result
      @result.value
    end

    def probability=(probability)
      @probability.value = probability.to_s
    end

    # 検査ウィジェットの削除
    def delete
      @test_frame.destroy
    end
  end
end
