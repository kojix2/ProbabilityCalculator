# 2013-2018 kojix2

# グラフ描出のためのクラス

class MainWindow
  class BoxChart
    def initialize(hoge, titlename, parent)
      @examinations = [] # 検査名の配列
      @sensitivities = []    # 感度の配列
      @specificities = []    # 特異度の配列

      @titlename = titlename
      @max = TkVariable.new(12.0)
      window = parent || TkToplevel.new(title: '検査特性')
      @f1 = TkFrame.new(window).pack(anchor: :nw)
      b1 = TkButton.new(@f1) do
        text '名前でソート'
        pack(side: :left)
      end
      b2 = TkButton.new(@f1) do
        text '感度でソート'
        pack(side: :left)
      end
      b3 = TkButton.new(@f1) do
        text '特異度でソート'
        pack(side: :left)
      end
      b4 = TkButton.new(@f1) do
        text 'LR+でソート'
        pack(side: :left)
      end
      b5 = TkButton.new(@f1) do
        text 'LR-でソート'
        pack(side: :left)
      end

      # TkLabel.new(@f1) do
      #  text 'max'
      #  pack(side: :left)
      # end
      # e1 = TkSpinbox.new(@f1, width:3, to:100, from:1, textvariable:@max).pack(:side=>:left)
      @h = TkCanvas.new(window) do
        bg :white
        pack(fill: :both, expand: true)
      end
      @h.configure(width: 400, height: (hoge.size.to_i * 20)) unless parent

      name = proc {
        clear_all
        hoge.each do |item|
          @examinations.unshift item[:examination]
          @sensitivities.unshift item[:sensitivity].to_i
          @specificities.unshift item[:specificity].to_i
        end
        plot_new1
      }
      Tk.update
      name.call
      b1.command name

      b2.command do
        clear_all
        hoge.sort_by { |item| item[:sensitivity].to_i }.each do |item|
          @examinations << item[:examination]
          @sensitivities << item[:sensitivity].to_i
          @specificities << item[:specificity].to_i
        end
        plot_new1
      end

      b3.command do
        clear_all
        hoge.sort_by { |item| item[:specificity].to_i }.each do |item|
          @examinations << item[:examination]
          @sensitivities << item[:sensitivity].to_i
          @specificities << item[:specificity].to_i
        end
        plot_new1
      end

      b4.command do
        clear_all
        hoge.sort_by { |item| item[:lr_positive].to_f }.each do |item|
          @examinations << item[:examination]
          @sensitivities << item[:lr_positive].to_f
          @specificities << if (1.0 / item[:lr_negative].to_f).finite?
                              1.0 / item[:lr_negative].to_f
                            else
                              0.0
                            end
        end
        temp = @sensitivities.max + 1.0
        @max.numeric = temp
        plot_new2
      end

      b5.command do
        clear_all
        hoge.sort_by do |item|
          if item[:lr_negative].nil?
            0.0
          else
            1.0 / item[:lr_negative].to_f
          end
        end.each do |item|
          @examinations << item[:examination]
          @sensitivities << item[:lr_positive].to_f
          @specificities << if item[:lr_negative].nil?
                              0.0
                            else
                              1.0 / item[:lr_negative].to_f
                            end
        end
        temp = @specificities.max + 1.0
        @max.numeric = temp
        plot_new2
      end
    end

    def clear_all
      @examinations.clear
      @sensitivities.clear
      @specificities.clear
    end

    def plot_new1
      @h.delete('all')
      s = Tk::Tcllib::Plotchart::HorizontalBarchart.new(@h, [0.0, 100.0, 20.0], @examinations, 2)
      s.plot('series2', @specificities, WINGREEN)
      s.plot('series1', @sensitivities, WINRED)
      s.title @titlename
    end

    def plot_new2
      @h.delete('all')
      s = Tk::Tcllib::Plotchart::HorizontalBarchart.new(@h, [0.0, @max.numeric, 1.0], @examinations, 2)
      s.plot('series2', @specificities, WINORANGE)
      s.plot('series1', @sensitivities, WINPURPLE)
      s.title @titlename
    end

    def destroy
      @f1.destroy
      if @h.destroy.nil?
        sleep 2
        @h.destroy
      end
    end
  end
end
