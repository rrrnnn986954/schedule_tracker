module ApplicationHelper
  def time_options_10min
    times = (0..23).flat_map { |h| [0,10,20,30,40,50].map { |m| format("%02d:%02d", h, m) } }
    times << "24:00"  # 終了専用
    times
  end

  # 表示・初期選択用: 終了が翌日00:00なら "24:00" を返す
  def hm_for(date, time, allow_24: false)
    return "" unless time
    if allow_24 && time == (date + 1).to_time.change(hour: 0, min: 0, sec: 0)
      "24:00"
    else
      time.strftime("%H:%M")
    end
  end
end
