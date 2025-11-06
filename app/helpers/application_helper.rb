module ApplicationHelper
  def time_options_10min
    times = (0..23).flat_map do |h|
      [0,10,20,30,40,50].map { |m| "%02d:%02d" % [h, m] }
    end
    times << "24:00"  # ← ✅ これを追加！
    times
  end
end
